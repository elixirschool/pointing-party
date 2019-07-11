defmodule PointingPartyWeb.CardController do
  use PointingPartyWeb, :controller
  alias PointingParty.Card

  def index(conn, _params) do
    # temporary, just to get something on the page for now
    card = Card.first()
    render(conn, "index.html", card: card)
  end
end
