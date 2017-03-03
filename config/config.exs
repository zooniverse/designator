# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :designator, Designator.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "qWURxQTs1g7D3K54EzegsyFU/n1Srt4fT2qfUqguDW+AkWVuVhDxz3/WCqLWpX82",
  render_errors: [accepts: ~w(json)],
  pubsub: [name: Designator.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :designator,
  namespace: Designator,
  ecto_repos: [Designator.Repo],
  reloader: Designator.Reloader.Async

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

if System.get_env("ROLLBAR_ACCESS_TOKEN") do
  config :rollbax,
    access_token: System.get_env("ROLLBAR_ACCESS_TOKEN"),
    environment: to_string(Mix.env)
else
    config :rollbax,
      access_token: "",
      environment: to_string(Mix.env),
      enabled: :log
end

