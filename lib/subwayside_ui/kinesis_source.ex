defmodule SubwaysideUi.KinesisSource do
  @moduledoc """
  Pulls events from the Kinesis stream for sending to the rest of SubwaysideUi.
  """
  use GenStage
  require Logger

  def start_link(opts) do
    start_link_opts = Keyword.take(opts, [:name])
    GenStage.start_link(__MODULE__, [], start_link_opts)
  end

  defstruct shard_iterator: nil, demand: 0

  @impl GenStage
  def init(_) do
    state = %__MODULE__{}
    send(self(), :fetch_iterator)
    {:producer, state, dispatcher: GenStage.BroadcastDispatcher}
  end

  @impl GenStage
  def handle_demand(demand, state) do
    old_demand = state.demand
    state = %{state | demand: old_demand + demand}

    if old_demand == 0 do
      send(self(), :timeout)
    end

    {:noreply, [], state}
  end

  @impl GenStage
  def handle_info(:fetch_iterator, state) do
    stream = ExAws.request!(ExAws.Kinesis.describe_stream(stream_name()))["StreamDescription"]
    shard_id = List.first(stream["Shards"])["ShardId"]

    shard_iterator =
      ExAws.request!(
        ExAws.Kinesis.get_shard_iterator(
          stream_name(),
          shard_id,
          :trim_horizon
        )
      )["ShardIterator"]

    state = %{state | shard_iterator: shard_iterator}
    {:noreply, [], state}
  end

  def handle_info(:timeout, state) do
    limit = min(state.demand, 10_000)
    response = ExAws.request(ExAws.Kinesis.get_records(state.shard_iterator, limit: limit))
    {events, state} = handle_response(response, state)
    {:noreply, events, state}
  end

  def decode!(<<120>> <> _rest = data) do
    data
    |> :zlib.uncompress()
    |> Jason.decode!()
  end

  def decode!("[" <> _rest = data) do
    Jason.decode!(data)
  end

  def decode!("{" <> _rest = data) do
    Jason.decode!(data)
  end

  def decode!(data) do
    data
    |> :zlib.unzip()
    |> Jason.decode!()
  end

  def handle_response({:ok, response}, state) do
    old_demand = state.demand

    events =
      response["Records"]
      |> Enum.flat_map(&(&1["Data"] |> :base64.decode() |> decode!()))
      |> Enum.map(fn
        %{"type" => "com.mbta.ctd.subwayside.train-heartbeat"} = record ->
          SubwaysideUi.Train.from_heartbeat(record)

        %{"type" => "com.mbta.ctd.subwayside.train-info", "data" => data} ->
          SubwaysideUi.Train.from_json_map(data)
      end)

    raw_byte_size =
      response["Records"]
      |> Enum.map(&byte_size(&1["Data"]))
      |> Enum.sum()

    decoded_byte_size =
      response["Records"]
      |> Enum.map(&byte_size(:base64.decode(&1["Data"])))
      |> Enum.sum()

    events_length = length(events)

    demand = max(0, old_demand - events_length)

    if response["Records"] != [] do
      Logger.info(
        "#{__MODULE__} received raw_byte_size=#{raw_byte_size} decoded_byte_size=#{decoded_byte_size} records=#{length(response["Records"])} events=#{events_length} sec_behind=#{div(response["MillisBehindLatest"], 1000)} demand=#{demand}"
      )
    end

    state = %{
      state
      | shard_iterator: response["NextShardIterator"],
        demand: demand
    }

    if state.demand > 0 do
      timeout =
        if response["MillisBehindLatest"] == 0 do
          fetch_interval_ms()
        else
          250
        end

      Process.send_after(self(), :timeout, timeout)
    end

    {events, state}
  end

  def handle_response({:error, {"ProvisionedThroughputExceededException", warning}}, state) do
    Logger.warn("#{__MODULE__} throughput exceeded warning=#{inspect(warning)}")
    Process.send_after(self(), :timeout, fetch_interval_ms())
    {[], state}
  end

  def stream_name do
    Keyword.fetch!(Application.get_env(:subwayside_ui, __MODULE__), :stream_name)
  end

  def fetch_interval_ms do
    Keyword.fetch!(Application.get_env(:subwayside_ui, __MODULE__), :fetch_interval_ms)
  end
end
