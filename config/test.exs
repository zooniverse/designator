use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cellect, Cellect.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :cellect, Cellect.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "marten",
  password: "",
  database: "cellect_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
