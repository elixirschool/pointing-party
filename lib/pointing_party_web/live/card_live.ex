defmodule PointingPartyWeb.CardLive do
  use Phoenix.LiveView

  alias PointingParty.{Card, VoteCalculator}
  alias PointingPartyWeb.Endpoint
  alias PointingPartyWeb.Presence
  @topic "pointing_party"

  def render(assigns) do
    Phoenix.View.render(PointingPartyWeb.CardView, "index.html", assigns)
  end

  def mount(%{username: username}, socket) do
    Endpoint.subscribe(@topic)
    Presence.track(self(), @topic, username, %{points: nil})
    {:ok, assign(socket, initial_state(username))}
  end

  def handle_event("start_party", _value, socket) do
    [first_card | remaining_cards] = Card.cards()
    payload = %{card: first_card, remaining: remaining_cards}
    Endpoint.broadcast(@topic, "party_started", payload)
    {:noreply, socket}
  end

  def handle_event("vote", %{"points" => points}, socket) do
    Presence.update(self(), @topic, socket.assigns.username, %{points: points})
    if everyone_voted?() do
      Endpoint.broadcast(@topic, "everyone_voted", %{})
    end

    {:noreply, socket}
  end

  def handle_event("next_card", points, socket) do
    Endpoint.broadcast(@topic, "update_card", %{points: points})

    {:noreply, socket}
  end

  def handle_info(%{event: "everyone_voted", topic: @topic}, socket) do
    {outcome, point_tally} =
      @topic
      |> Presence.list()
      |> VoteCalculator.calculate_votes()

    {:noreply, assign(socket, outcome: outcome, point_tally: point_tally)}
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

  def handle_info(
    %{event: "presence_diff"},
    socket) do
    users = Presence.list(@topic)

    {:noreply, assign(socket, users: users)}
  end

  def handle_info(%{event: "update_card", payload: %{points: points}, topic: @topic}, socket) do
    updated_socket = save_vote_next_card(points, socket)

    Presence.update(self(), @topic, updated_socket.assigns.username, %{points: nil})

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

  def everyone_voted? do
    @topic
    |> Presence.list()
    |> Enum.map(fn {_username, %{metas: [%{points: points}]}} -> points end)
    |> Enum.all?(&(&1))
  end
end
