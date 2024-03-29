# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :subwayside_ui, SubwaysideUi.StageSupervisor, start?: true

config :subwayside_ui, SubwaysideUi.KinesisSource, fetch_interval_ms: 1000
# Configures the endpoint
config :subwayside_ui, SubwaysideUiWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: SubwaysideUiWeb.ErrorHTML, json: SubwaysideUiWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: SubwaysideUi.PubSub,
  live_view: [signing_salt: "Gjj0V7iV"]

config :subwayside_ui, SubwaysideUi.GTFS.TrainCrowdingStatus,
  feed_func: {SubwaysideUi.GTFS.TrainCrowdingStatus, :get_gtfs_realtime_feed, []}

config :subwayside_ui, SubwaysideUi.GTFS,
  # Which GTFS-RT (JSON) feed to load:
  url:
    System.get_env("SUBWAYSIDEUI_VEHICLEPOSITIONS_URL") ||
      "https://mbta-gtfs-s3.s3.amazonaws.com/rtr/VehiclePositions_enhanced.json",
  # Hide trains that don't have at least one car in GTFS-RT feed:
  only_show_gtfs: true

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.7",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ex_aws,
  json_codec: Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
