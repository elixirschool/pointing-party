defmodule PointingPartyWeb.CardLive do
  use Phoenix.LiveView

  alias PointingParty.{Card, VoteCalculator}

  def render(assigns) do
    Phoenix.View.render(PointingPartyWeb.CardView, "index.html", assigns)
  end

  def mount(%{username: username}, socket) do
    {:ok, assign(socket, initial_state(username))}
  end

  def handle_event("start_party", _value, socket) do
    [first_card | remaining_cards] = Card.cards()
    updated_socket =
      socket
      |> assign(:is_pointing, true)
      |> assign(:current_card, first_card)
      |> assign(:remaining_cards, remaining_cards)
    {:noreply, updated_socket}
  end

  ## Helper Methods ##

  defp initial_state(username) do
    [
      current_card: nil,
      outcome: nil,
      is_pointing: false,
      remaining_cards: [],
      completed_cards: [],
      point_tally: nil,
      users: [],
      username: username
    ]
  end
end
