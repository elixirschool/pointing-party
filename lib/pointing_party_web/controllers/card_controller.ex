defmodule PointingPartyWeb.CardController do
  use PointingPartyWeb, :controller

  import Phoenix.LiveView.Controller
  alias PointingPartyWeb.CardLive

  def index(conn, _params) do
    %{assigns: %{username: username}} = conn
    live_render(conn, CardLive, session: %{username: username})
  end
end
