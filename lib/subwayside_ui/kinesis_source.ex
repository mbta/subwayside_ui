defmodule SubwaysideUi.KinesisSource do
  @moduledoc """
  Pulls events from the Kinesis stream for sending to the rest of SubwaysideUi.
  """
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  defstruct shard_iterator: nil

  def init(_) do
    state = %__MODULE__{}
    {:ok, state, {:continue, :fetch_iterator}}
  end

  def handle_continue(:fetch_iterator, state) do
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
    send(self(), :timeout)
    {:noreply, state}
  end

  def handle_info(:timeout, state) do
    response = ExAws.request!(ExAws.Kinesis.get_records(state.shard_iterator))
    state = %{state | shard_iterator: response["NextShardIterator"]}

    events =
      response["Records"]
      |> Enum.flat_map(&(&1["Data"] |> :base64.decode() |> Jason.decode!()))

    if response["Records"] != [] do
      Logger.info(
        "#{__MODULE__} received records=#{length(response["Records"])} events=#{length(events)}"
      )
    end

    timeout =
      if response["MillisBehindLatest"] == 0 do
        fetch_interval_ms()
      else
        0
      end

    {:noreply, state, timeout}
  end

  def stream_name do
    Application.get_env(:subwayside_ui, __MODULE__)[:stream_name]
  end

  def fetch_interval_ms do
    Application.get_env(:subwayside_ui, __MODULE__)[:fetch_interval_ms]
  end
end
