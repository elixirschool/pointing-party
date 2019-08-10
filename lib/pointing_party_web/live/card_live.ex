defmodule PointingPartyWeb.CardLive do
  use Phoenix.LiveView

  alias PointingParty.{Card, VoteCalculator}
  alias PointingPartyWeb.{Endpoint, Presence}

  @topic "pointing_party"

  def render(assigns) do
    Phoenix.View.render(PointingPartyWeb.CardView, "index.html", assigns)
  end

  def mount(%{username: username}, socket) do
    Endpoint.subscribe(@topic)
    {:ok, _} = Presence.track(self(), @topic, username, %{points: nil})

    assigns = [
      current_card: nil,
      outcome: nil,
      is_pointing: false,
      points_range: Card.points_range(),
      remaining_cards: [],
      point_tally: nil,
      username: username,
      users: Presence.list(@topic),
      completed_cards: []
    ]

    {:ok, assign(socket, assigns)}
  end

  def handle_event("next_card", points, socket) do
    Endpoint.broadcast(@topic, "update_card", %{points: points})

    {:noreply, socket}
  end

  def handle_event("start_party", _, socket) do
    [current_card | remaining_cards] = Card.cards()
    Endpoint.broadcast(@topic, "party_started", %{card: current_card, remaining_cards: remaining_cards})

    {:noreply, socket}
  end

  def handle_event("vote", %{"points" => points}, socket) do
    Presence.update(self(), @topic, socket.assigns.username, &Map.put(&1, :points, points))

    if everyone_voted?() do
      Endpoint.broadcast(@topic, "everyone_voted", %{})
    end

    {:noreply, socket}
  end

  def handle_info(%{event: "everyone_voted", topic: @topic}, socket) do
    {outcome, point_tally} =
      @topic
      |> Presence.list()
      |> VoteCalculator.calculate_votes()

    {:noreply, assign(socket, outcome: outcome, point_tally: point_tally)}
  end

  def handle_info(%{event: "party_started", payload: payload, topic: @topic}, socket) do
    %{card: card, remaining_cards: remaining_cards} = payload

    {:noreply, assign(socket, current_card: card, is_pointing: true, remaining_cards: remaining_cards)}
  end

  def handle_info(%{event: "presence_diff"}, socket) do
    {:noreply, assign(socket, users: Presence.list(@topic))}
  end

  def handle_info(%{event: "update_card", payload: %{points: points}, topic: @topic}, socket) do
    updated_socket = save_vote_next_card(points, socket)
    Presence.update(self(), @topic, updated_socket.assigns.username, &Map.put(&1, :points, nil))

    {:noreply, updated_socket}
  end

  ## Helper Functions ##

  defp everyone_voted? do
    @topic
    |> Presence.list()
    |> Enum.map(fn {_username, %{metas: [%{points: points}]}} -> points end)
    |> Enum.all?(&(&1))
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
