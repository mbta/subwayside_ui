import Config

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix assets.deploy` task,
# which you should run after static files are built and
# before starting your production server.
config :subwayside_ui, SubwaysideUiWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  secure_pipeline: [
    rewrite_on: [:x_forwarded_host, :x_forwarded_port, :x_forwarded_proto],
    hsts: true
  ]

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
