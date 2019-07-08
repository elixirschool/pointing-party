use Mix.Config

# Configure your database
config :pointing_party, PointingParty.Repo,
  username: "postgres",
  password: "postgres",
  database: "pointing_party_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :pointing_party, PointingPartyWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
