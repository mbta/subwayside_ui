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
      |> Enum.flat_map(& &1["data"]["car_infos"])
      |> Enum.reduce(state, &update_state/2)

    {:noreply, [], state}
  end

  defp update_state(car_info, state) do
    %{
      "car_nbr" => car_nbr,
      "load_weight_sig_1" => weight_1,
      "load_weight_sig_2" => weight_2
    } = car_info

    weight = SubwaysideUi.car_weight(weight_1, weight_2)

    cars = Map.update(state.cars, car_nbr, weight, fn old -> min(old, weight) end)
    %{state | cars: cars}
  end
end
