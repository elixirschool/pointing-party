defmodule PointingPartyWeb.CardController do
  use PointingPartyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
