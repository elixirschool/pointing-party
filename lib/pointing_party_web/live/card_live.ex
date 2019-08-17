defmodule PointingPartyWeb.CardLive do
  use Phoenix.LiveView

  alias PointingParty.Card
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
    Presence.update(self(), "users", socket.assigns.username, &Map.put(&1, :points, nil))
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

    {event, results} =
      case winning_vote(current_users) do
        top_two when is_list(top_two) -> {"tie", top_two}
        winner -> {"winner", winner}
      end

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

  defp winning_vote(users) do
    votes = Enum.map(users, fn {_username, %{metas: [%{points: points}]}} -> points end)

    calculated_votes = Enum.reduce(votes, %{}, fn vote, acc ->
      acc
      |> Map.get_and_update(vote, &({&1, (&1 || 0) + 1}))
      |> elem(1)
    end)

    total_votes = length(votes)

    majority = Enum.reduce_while(calculated_votes, nil, fn {point, vote_count}, _acc ->
      if vote_count == total_votes or rem(vote_count, total_votes) > 5 do
        {:halt, point}
      else
        {:cont, nil}
      end
    end)

    if is_nil(majority) do
      calculated_votes
      |> Enum.sort_by(&elem(&1, 1))
      |> Enum.take(2)
      |> Enum.map(&elem(&1, 0))
    else
      majority
    end
  end
end
