defmodule SubwaysideUi.MinimumWeight do
  @moduledoc """
  Maintains the minimum weight for each car.

  Using this, we can see how much additional weight is present.
  """
  use GenStage
  require Logger

  def start_link(opts) do
    start_link_opts = Keyword.take(opts, [:name])
    GenStage.start_link(__MODULE__, opts, start_link_opts)
  end

  def weight(server, car_nbr) do
    GenStage.call(server, {:weight, car_nbr})
  end

  defstruct cars: %{}

  @impl GenStage
  def init(opts) do
    state = %__MODULE__{}
    init_opts = Keyword.take(opts, [:subscribe_to])
    {:consumer, state, init_opts}
  end

  @impl GenStage
  def handle_call({:weight, car_nbr}, _from, state) do
    {:reply, Map.fetch(state.cars, car_nbr), [], state}
  end

  @impl GenStage
  def handle_events(events, _from, state) do
    state =
      events
      |> Enum.flat_map(&Enum.zip(&1["data"]["car_infos"], &1["data"]["car_lists"]))
      |> Enum.reduce(state, &update_state/2)

    {:noreply, [], state}
  end

  defp update_state({info, list}, state) do
    car = SubwaysideUi.Car.from_json_maps(info, list)

    if car.weight > 50_000 do
      cars = Map.update(state.cars, car.car_nbr, car.weight, fn old -> min(old, car.weight) end)
      %{state | cars: cars}
    else
      Logger.warn(
        "invalid weight car=#{car.car_nbr} info=#{Jason.encode!(info)} list=#{Jason.encode!(list)}"
      )

      state
    end
  end
end
