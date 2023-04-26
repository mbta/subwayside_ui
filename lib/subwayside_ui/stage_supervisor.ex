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
    children = [
      {SubwaysideUi.KinesisSource, name: SubwaysideUi.KinesisSource},
      {SubwaysideUi.TrainStatus,
       name: SubwaysideUi.TrainStatus, subscribe_to: [SubwaysideUi.KinesisSource]}
    ]

    opts = [
      strategy: :rest_for_one
    ]

    Supervisor.init(children, opts)
  end
end
