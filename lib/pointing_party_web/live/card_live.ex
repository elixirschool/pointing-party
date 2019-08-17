defmodule PointingPartyWeb.CardLive do
  use Phoenix.LiveView

  alias PointingParty.{Card, VoteCalculator}
  alias PointingPartyWeb.{Endpoint, Presence}

  def render(assigns) do
    Phoenix.View.render(PointingPartyWeb.CardView, "index.html", assigns)
  end

  def mount(%{username: username}, socket) do
    Endpoint.subscribe("users")
    {:ok, _} = Presence.track(self(), "users", username, %{points: nil})
    assigns = [
      current_card: nil,
      is_driving: false,
      outcome: nil,
      party_has_started: false,
      remaining_cards: [],
      results: nil,
      username: username,
      users: Presence.list("users"),
      votes: []
    ]

    {:ok, assign(socket, assigns)}
  end

  def handle_event("next_card", points, socket) do
    updated_socket = save_vote_next_card(points, socket)
    Presence.update(self(), "users", updated_socket.assigns.username, &Map.put(&1, :points, nil))
    Endpoint.broadcast_from(self(), "users", "update_card", %{card: updated_socket.assigns.current_card})

    {:noreply, updated_socket}
  end

  def handle_event("start_party", _, socket) do
    [current_card | remaining_cards] = Card.cards()
    Endpoint.broadcast("users", "party_started", %{card: current_card})

    {:noreply, assign(socket, is_driving: true, remaining_cards: remaining_cards)}
  end

  def handle_event("vote", %{"points" => points}, socket) do
    Presence.update(self(), "users", socket.assigns.username, &Map.put(&1, :points, points))

    if everyone_voted?() do
      Endpoint.broadcast("users", "everyone_voted", %{})
    end

    {:noreply, socket}
  end

  def handle_info(%{event: "everyone_voted", topic: "users"}, socket) do
    if socket.assigns.is_driving do
      finalize_voting()
    end

    {:noreply, socket}
  end

  def handle_info(%{event: "party_started", payload: %{card: card}, topic: "users"}, socket) do
    {:noreply, assign(socket, current_card: card, party_has_started: true)}
  end

  def handle_info(%{event: "presence_diff"}, socket) do
    {:noreply, assign(socket, users: Presence.list("users"))}
  end

  def handle_info(%{event: "tie", payload: %{results: results}, topic: "users"}, socket) do
    {:noreply, assign(socket, outcome: "tie", results: results)}
  end

  def handle_info(%{event: "update_card", payload: %{card: card}, topic: "users"}, socket) do
    Presence.update(self(), "users", socket.assigns.username, &Map.put(&1, :points, nil))
    {:noreply, assign(socket, current_card: card, outcome: nil)}
  end

  def handle_info(%{event: "winner", payload: %{results: results}, topic: "users"}, socket) do
    {:noreply, assign(socket, outcome: "winner", results: results)}
  end

  defp everyone_voted? do
    "users"
    |> Presence.list()
    |> Enum.map(fn {_username, %{metas: [metas]}} -> Map.get(metas, :points) end)
    |> Enum.all?(&(not is_nil(&1)))
  end

  defp finalize_voting do
    current_users = Presence.list("users")
    {event, results} = VoteCalculator.calculate_votes(current_users)

    Endpoint.broadcast("users", event, %{results: results})
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
    |> assign(:votes, [latest_card | socket.assigns[:votes]])
  end
end
