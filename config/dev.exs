import Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with esbuild to bundle .js and .css sources.
config :subwayside_ui, SubwaysideUiWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "9aK3FazdcUQRF8gt8CKzpz0KLk27a06hZV+Vb6gsha1UBy/eVnQqu6PWUXy+8A3e",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

# Watch static and templates for browser reloading.
config :subwayside_ui, SubwaysideUiWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/subwayside_ui_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Enable dev routes for dashboard and mailbox
config :subwayside_ui, dev_routes: true

if stream_name = System.get_env("KINESIS_STREAM_NAME") do
  # using a real Kinesis stream
  config :subwayside_ui, SubwaysideUi.KinesisSource, stream_name: stream_name

  config :ex_aws,
    access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, {:awscli, :system, 5_000}],
    secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, {:awscli, :system, 5_000}]
else
  config :ex_aws,
    access_key_id: "test",
    secret_access_key: "test",
    region: "us-east-1"

  config :ex_aws, :kinesis,
    scheme: "http://",
    host: "localhost",
    port: 4566,
    region: "us-east-1"

  config :subwayside_ui, SubwaysideUi.KinesisSource, stream_name: "ctd-subwayside"
end

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
