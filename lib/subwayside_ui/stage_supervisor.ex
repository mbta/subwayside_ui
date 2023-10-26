defmodule SubwaysideUi.StageSupervisor do
  @moduledoc """
  Supervisor for the GenStage pipeline children.
  """
  use Supervisor

  def start_link(_) do
    if Application.get_env(:subwayside_ui, __MODULE__)[:start?] do
      Supervisor.start_link(__MODULE__, [])
    else
      :ignore
    end
  end

  @impl Supervisor
  def init([]) do
    max_demand = 10_000
    subscribe_to = [{SubwaysideUi.KinesisSource, max_demand: max_demand}]

    children = [
      {SubwaysideUi.KinesisSource, name: SubwaysideUi.KinesisSource},
      {SubwaysideUi.MinimumWeight, name: SubwaysideUi.MinimumWeight, subscribe_to: subscribe_to},
      {SubwaysideUi.TrainStatus, name: SubwaysideUi.TrainStatus, subscribe_to: subscribe_to},
      SubwaysideUi.CrowdingLogger,
      SubwaysideUi.GTFS
    ]

    opts = [
      strategy: :rest_for_one
    ]

    Supervisor.init(children, opts)
  end
end
