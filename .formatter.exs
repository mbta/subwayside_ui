[
  import_deps: [:phoenix, :json_formatter],
  plugins: [Phoenix.LiveView.HTMLFormatter, JsonFormatter],
  inputs: ["*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}"]
]
