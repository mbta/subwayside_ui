defmodule SubwaysideUi.TrainStatus do
  @moduledoc """
  Maintains the state of each train.
  """
  use GenStage
  require Logger

  def start_link(opts) do
    start_link_opts = Keyword.take(opts, [:name])
    GenStage.start_link(__MODULE__, opts, start_link_opts)
  end

  def trains(server) do
    GenStage.call(server, :trains)
  end

  def listen(server, pid) do
    GenStage.call(server, {:listen, pid})
  end

  defstruct trains: %{}, listeners: %{}

  @impl GenStage
  def init(opts) do
    state = %__MODULE__{}
    init_opts = Keyword.take(opts, [:subscribe_to])
    {:consumer, state, init_opts}
  end

  @impl GenStage
  def handle_call(:trains, _from, state) do
    {:reply, state.trains, [], state}
  end

  @impl GenStage
  def handle_call({:listen, pid}, _from, state) do
    monitor = Process.monitor(pid)
    state = %{state | listeners: Map.put(state.listeners, pid, monitor)}
    {:reply, state.trains, [], state}
  end

  @impl GenStage
  def handle_info({:DOWN, _monitor, :process, pid, _reason}, state) do
    state = %{state | listeners: Map.delete(state.listeners, pid)}
    {:noreply, [], state}
  end

  @impl GenStage
  def handle_events(events, _from, state) do
    state = Enum.reduce(events, state, &update_state/2)
    state = clear_stale_trains(state)

    for pid <- Map.keys(state.listeners) do
      Logger.info("#{__MODULE__} notifying #{inspect(pid)}")
      send(pid, :new_trains)
    end

    {:noreply, [], state}
  end

  defp update_state(event, state) do
    %{
      "data" =>
        %{
          "train_id" => train_id
        } = data
    } = event

    Logger.info("#{__MODULE__} updated train_id=#{train_id}")
    %{state | trains: Map.put(state.trains, train_id, data)}
  end

  defp clear_stale_trains(state) do
    old_iso =
      DateTime.utc_now()
      |> DateTime.add(-5, :minute)
      |> DateTime.to_iso8601()

    trains =
      Map.filter(state.trains, fn {_key, value} ->
        value["created_date"] >= old_iso
      end)

    %{state | trains: trains}
  end
end
