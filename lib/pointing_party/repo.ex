defmodule PointingParty.Repo do
  use Ecto.Repo,
    otp_app: :pointing_party,
    adapter: Ecto.Adapters.Postgres
end
