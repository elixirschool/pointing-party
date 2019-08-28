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
    %{event: "presence_diff", payload: payload},
    socket) do
    leaves = Map.keys(payload.leaves) |> List.first()
    IO.puts "LEAVES"
    IO.inspect leaves
    users = Presence.list(@topic)
    updated_socket = update_socket_with_leaves(socket, users, leaves)
    {:noreply, updated_socket}
  end

  def handle_event("vote_submit", %{"points" => points}, socket) do
    Presence.update(self(), @topic, socket.assigns.username, %{points: points})
    if everyone_voted?() do
      {outcome, point_tally} = VoteCalculator.calculate_votes(Presence.list(@topic))
      Endpoint.broadcast(@topic, "votes_calculated", %{outcome: outcome, point_tally: point_tally})
    end
    {:noreply, socket}
  end

  def handle_event("next_card", winning_points, socket) do
    Endpoint.broadcast(@topic, "new_card", %{points: winning_points})
    {:noreply, socket}
  end

  def handle_info(%{event: "new_card", payload: %{points: points}}, socket) do
    updated_socket = save_vote_next_card(points, socket)
    Presence.update(self(), @topic, socket.assigns.username, %{points: nil})
    {:noreply, updated_socket}
  end

  def handle_info(%{event: "votes_calculated", payload: payload}, socket) do
    updated_socket =
      socket
      |> assign(:outcome, payload.outcome)
      |> assign(:point_tally, payload.point_tally)
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
      users: Presence.list(@topic),
      username: username,
      leaves: nil
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
    |> assign(:point_tally, nil)
    |> assign(:completed_cards, [latest_card | socket.assigns[:completed_cards]])
  end

  def everyone_voted? do
    @topic
    |> Presence.list()
    |> Enum.map(fn {_username, %{metas: [%{points: points}]}} -> points end)
    |> Enum.all?(&(&1))
  end

  def update_socket_with_leaves(socket, users, nil) do
    socket
    |> assign(users: users)
  end

  def update_socket_with_leaves(socket, users, leaves) do
    socket
    |> assign(:users, users)
    |> assign(:leaves, leaves)
  end
end
