defmodule Designator.Mixfile do
  use Mix.Project

  def project do
    [app: :designator,
     version: "0.0.1",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: (Mix.env == :prod || Mix.env == :bench),
     start_permanent: (Mix.env == :prod || Mix.env == :bench),
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Designator, []},
     applications: [:phoenix, :phoenix_pubsub, :cowboy, :logger, :gettext,
                    :phoenix_ecto, :postgrex, :logster, :rollbax, :con_cache]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.0"},
     {:phoenix_pubsub, "~> 1.0"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_ecto, "~> 3.0-rc"},
     {:gettext, "~> 0.9"},
     {:cowboy, "~> 1.0"},
     {:array, git: "https://github.com/mhib/elixir-array.git"},
     {:logster, "~> 0.4"},
     {:credo, "~> 0.6", only: [:dev, :test]},
     {:rollbax, "~> 0.8"},
     {:mock, "~> 0.2.0", only: :test},
     {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
     {:con_cache, "~> 0.12.0"},
     {:basic_auth, "~> 2.0.0"}]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test":       ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
