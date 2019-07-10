defmodule PointingPartyWeb.CardController do
  use PointingPartyWeb, :controller
  alias PointingParty.Card

  def index(conn, _params) do
    # temporary, just to get something on the page for now
    card = Card.get!(1)
    render(conn, "index.html", card: card)
  end
end
