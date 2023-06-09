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

  def has_trains?(server) do
    GenStage.call(server, :has_trains?)
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
  def handle_call(:has_trains?, _from, state) do
    {:reply, state.trains != [], [], state}
  end

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
    now = DateTime.utc_now()
    old = DateTime.add(now, -5, :minute)

    state =
      events
      |> Enum.filter(&(DateTime.compare(&1.receive_date, old) != :lt))
      |> Enum.reduce(state, &update_state/2)
      |> clear_stale_trains(old)

    if map_size(state.trains) > 0 do
      for pid <- Map.keys(state.listeners) do
        Logger.info("#{__MODULE__} notifying #{inspect(pid)}")
        send(pid, :new_trains)
      end
    end

    {:noreply, [], state}
  end

  defp update_state(train, state) do
    Logger.info("#{__MODULE__} updated train_id=#{train.id} created_date=#{train.created_date}")

    %{state | trains: Map.put(state.trains, train.id, train)}
  end

  defp clear_stale_trains(state, old) do
    trains =
      Map.filter(state.trains, fn {_key, train} ->
        DateTime.compare(train.created_date, old) != :lt
      end)

    %{state | trains: trains}
  end
end
