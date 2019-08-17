defmodule PointingPartyWeb.CardController do
  use PointingPartyWeb, :controller

  import Phoenix.LiveView.Controller

  def index(%{assigns: %{username: username}} = conn, _params) do
    live_render(conn, PointingPartyWeb.CardLive, session: %{username: username})
  end
end
