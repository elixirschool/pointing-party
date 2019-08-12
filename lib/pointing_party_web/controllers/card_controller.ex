defmodule PointingPartyWeb.CardController do
  use PointingPartyWeb, :controller

  import Phoenix.LiveView.Controller

  def index(conn, _params) do
    # render(conn, "index.html")
    live_render(conn, PointingPartyWeb.LiveCardView, session: %{})
  end
end
