use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :designator, DesignatorWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :designator, Designator.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("POSTGRES_USER") || System.get_env("USER"),
  password: System.get_env("POSTGRES_PASS") || "",
  database: System.get_env("POSTGRES_DB")   || "designator_test",
  hostname: System.get_env("POSTGRES_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :designator,
  reloader: Designator.Reloader.Sync
