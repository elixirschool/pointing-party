defmodule PointingPartyWeb.CardController do
  use PointingPartyWeb, :controller
  alias PointingParty.Card

  def index(conn, _params) do
    # temporary, just to get something on the page for now
    card = Card.first()
    points = Card.points_range()
    render(conn, "index.html", card: card, points: points)
  end
end
