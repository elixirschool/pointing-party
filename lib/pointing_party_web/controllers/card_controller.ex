defmodule PointingPartyWeb.CardController do
  use PointingPartyWeb, :controller
  plug :authenticate_user
  alias PointingParty.Card

  def index(conn, _params) do
    # temporary, just to get something on the page for now
    card = Card.get!(1)
    render(conn, "index.html", card: card)
  end

  def authenticate_user(conn, _params) do
    case get_session(conn, :username) do
      nil -> redirect(conn, to: "/login") |> halt()
      username -> assign(conn, :username, username)
    end
  end
end
