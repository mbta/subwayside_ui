defmodule SubwaysideUi.CrowdingLogger do
  @moduledoc """
  Logs crowding levels when the trains update, for future spot checking.
  """

  use GenServer
  require Logger

  alias SubwaysideUi.Car

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  defstruct [
    :last_received,
    train_status: SubwaysideUi.TrainStatus
  ]

  @impl GenServer
  def init(_opts) do
    state = %__MODULE__{last_received: DateTime.utc_now()}
    _trains = SubwaysideUi.TrainStatus.listen(state.train_status, self())
    {:ok, state}
  end

  @impl GenServer
  def handle_info(:new_trains, state) do
    new_trains =
      state.train_status
      |> SubwaysideUi.TrainStatus.trains()
      |> Map.values()
      |> Enum.filter(&(DateTime.compare(&1.receive_date, state.last_received) == :gt))

    if new_trains == [] do
      {:noreply, state}
    else
      last_received = Enum.max_by(new_trains, & &1.receive_date, DateTime).receive_date

      for train <- new_trains do
        log_crowding(train)
      end

      state = %{state | last_received: last_received}
      {:noreply, state}
    end
  end

  defp log_crowding(train) do
    for car <- train.cars do
      {:ok, car_base_weight} =
        SubwaysideUi.MinimumWeight.weight(SubwaysideUi.MinimumWeight, car.car_nbr)

      passengers = div(car.weight - car_base_weight, 155)
      aw1 = Car.aw1(car)
      aw2 = Car.aw2(car)

      crowding =
        cond do
          passengers <= aw1 -> :not_crowded
          passengers <= aw2 -> :some_crowding
          true -> :crowded
        end

      Logger.info(
        "#{__MODULE__} train_id=#{train.id} leader_car=#{train.leader_car_nbr} car=#{car.car_nbr} weight=#{car.weight} base_weight=#{car_base_weight} passengers=#{passengers} crowding=#{crowding} created_date=#{train.created_date}"
      )
    end
  end
end
