defmodule PointingPartyWeb.CardLive do
  use Phoenix.LiveView

  import PointingParty.Card, only: [cards: 0]

  alias PointingPartyWeb.{Endpoint, Presence}

  def render(assigns) do
    Phoenix.View.render(PointingPartyWeb.CardView, "index.html", assigns)
  end

  def mount(%{username: username}, socket) do
    Endpoint.subscribe("users") # Does this need to be different than the Presence channel?
    {:ok, _} = Presence.track(self(), "users", username, %{points: nil})
    assigns = [
      is_driving: false,
      outcome: nil,
      party_has_started: false,
      username: username,
      users: Presence.list("users")
    ]

    {:ok, assign(socket, assigns)}
  end

  def handle_event("start_party", _, socket) do
    Endpoint.broadcast("users", "party_started", %{})

    {:noreply, assign(socket, is_driving: true)}
  end

  def handle_event("vote", %{"points" => points}, socket) do
    Presence.update(self(), "users", socket.assigns.username, &Map.put(&1, :points, points))

    if everyone_voted?() do
      finalize_voting()
    end

    {:noreply, socket}
  end

  def handle_info(%{event: "presence_diff"}, socket) do
    {:noreply, assign(socket, users: Presence.list("users"))}
  end

  def handle_info(%{event: "party_started", topic: "users"}, socket) do
    {:noreply, assign(socket, card: List.first(cards()), party_has_started: true)}
  end

  def handle_info(%{event: "tie", payload: %{results: results}, topic: "users"}, socket) do
    {:noreply, assign(socket, outcome: "tie", results: results)}
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
