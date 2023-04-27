defmodule SubwaysideUi.MixProject do
  use Mix.Project

  def project do
    [
      app: :subwayside_ui,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: LcovEx],
      releases: [
        subwayside_ui: [
          include_executables_for: [:unix]
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {SubwaysideUi.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.2"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.18.16"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.7.2"},
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:json_formatter, "~> 0.2.0", only: [:dev], runtime: false},
      {:plug_cowboy, "~> 2.5"},
      {:ex_aws, "~> 2.4"},
      {:hackney, "~> 1.18"},
      {:ex_aws_kinesis, "~> 2.0"},
      {:gen_stage, "~> 1.2"},
      {:sobelow, "~> 0.12.2", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false},
      {:credo, "~> 1.7", only: [:dev], runtime: false},
      {:mix_audit, "~> 2.1", only: [:dev], runtime: false},
      {:lcov_ex, "~> 0.3.2", only: [:test], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
      ci: [
        "format",
        "compile --force --warnings-as-errors",
        "hex.audit",
        "deps.audit",
        "credo --strict",
        "sobelow --skip --exit",
        "dialyzer"
      ]
    ]
  end
end
