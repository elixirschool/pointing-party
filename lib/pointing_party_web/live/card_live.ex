defmodule PointingPartyWeb.CardLive do
  use Phoenix.LiveView

  alias PointingParty.{Card, VoteCalculator}
  alias PointingPartyWeb.Endpoint
  @topic "pointing_party"

  def render(assigns) do
    Phoenix.View.render(PointingPartyWeb.CardView, "index.html", assigns)
  end

  def mount(%{username: username}, socket) do
    Endpoint.subscribe(@topic)
    {:ok, assign(socket, initial_state(username))}
  end

  def handle_event("start_party", _value, socket) do
    [first_card | remaining_cards] = Card.cards()
    payload = %{card: first_card, remaining: remaining_cards}
    Endpoint.broadcast(@topic, "party_started", payload)
    {:noreply, socket}
  end

  def handle_info(%{
    event: "party_started",
    payload: %{card: card, remaining: remaining},
    topic: @topic}, socket) do

      {:noreply, assign(
        socket,
        current_card: card,
        remaining_cards: remaining,
        is_pointing: true)}
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

  defp save_vote_next_card(points, socket) do
    latest_card =
      socket.assigns
      |> Map.get(:current_card)
      |> Map.put(:points, points)

    {next_card, remaining_cards} =
      socket.assigns
      |> Map.get(:remaining_cards)
      |> List.pop_at(0)

    socket
    |> assign(:remaining_cards, remaining_cards)
    |> assign(:current_card, next_card)
    |> assign(:outcome, nil)
    |> assign(:completed_cards, [latest_card | socket.assigns[:completed_cards]])
  end
end
