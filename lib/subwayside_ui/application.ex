defmodule SubwaysideUi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      SubwaysideUiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SubwaysideUi.PubSub},
      # Start the Endpoint (http/https)
      SubwaysideUiWeb.Endpoint,
      # Start a worker by calling: SubwaysideUi.Worker.start_link(arg)
      # {SubwaysideUi.Worker, arg},
      SubwaysideUi.StageSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SubwaysideUi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SubwaysideUiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
