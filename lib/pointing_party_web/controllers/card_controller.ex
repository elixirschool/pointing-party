defmodule PointingPartyWeb.CardController do
  use PointingPartyWeb, :controller

  import Phoenix.LiveView.Controller

  def index(conn, _params) do
    %{assigns: %{username: username}} = conn

    live_render(conn, PointingPartyWeb.CardLive, session: %{username: username})
  end
end
