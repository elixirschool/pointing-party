defmodule PointingPartyWeb.Presence do
  use Phoenix.Presence,
    otp_app: :pointing_party,
    pubsub_server: PointingParty.PubSub
end
