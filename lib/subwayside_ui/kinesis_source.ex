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
    response = ExAws.request!(ExAws.Kinesis.get_records(state.shard_iterator, limit: limit))
    old_demand = state.demand

    events =
      response["Records"]
      |> Enum.flat_map(&(&1["Data"] |> :base64.decode() |> Jason.decode!()))

    events_length = length(events)

    demand = max(0, old_demand - events_length)

    if response["Records"] != [] do
      Logger.info(
        "#{__MODULE__} received records=#{length(response["Records"])} events=#{events_length} sec_behind=#{div(response["MillisBehindLatest"], 1000)} demand=#{demand}"
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

    {:noreply, events, state}
  end

  def stream_name do
    Application.get_env(:subwayside_ui, __MODULE__)[:stream_name]
  end

  def fetch_interval_ms do
    Application.get_env(:subwayside_ui, __MODULE__)[:fetch_interval_ms]
  end
end
