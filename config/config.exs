use Mix.Config

config :pointing_party,
  ecto_repos: [PointingParty.Repo]

# Configures the endpoint
config :pointing_party, PointingPartyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "w1I+WClCAIRKxSX5/M7gFHQLa9pnn4AuVDO6XmUgTZxJl+VqMOr2Q5Ou+2CSoLdJ",
  render_errors: [view: PointingPartyWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PointingParty.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

import_config "cards.exs"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
