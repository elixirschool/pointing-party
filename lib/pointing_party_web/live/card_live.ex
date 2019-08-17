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
      party_has_started: false,
      show_votes: false,
      tentative_points: 1,
      username: username,
      users: Presence.list("users")
    ]

    {:ok, assign(socket, assigns)}
  end

  def handle_event("start_party", _, socket) do
    Endpoint.broadcast_from(self(), "users", "party_started", %{})

    {:noreply, assign(socket, card: List.first(cards()), party_has_started: true)}
  end

  def handle_event("tentative_vote", %{"points" => points}, socket) do
    {:noreply, assign(socket, tentative_points: points)}
  end

  def handle_event("vote", _points, socket) do
    Presence.update(self(), "users", socket.assigns.username, &Map.put(&1, :points, socket.assigns.tentative_points))

    if everyone_voted?() do
      {:noreply, assign(socket, show_votes: true, users: Presence.list("users"))}
    else
      {:noreply, socket}
    end
  end

  def handle_info(%{event: "presence_diff"}, msg) do
    IO.puts "presence diff"
    IO.inspect msg

    {:noreply, msg}
  end

  def handle_info(%{event: "party_started", topic: "users"}, socket) do
    IO.puts "party started!"

    {:noreply, assign(socket, card: List.first(cards()), party_has_started: true)}
  end

  defp everyone_voted? do
    "users"
    |> Presence.list()
    |> Enum.map(fn {_username, %{metas: [metas]}} -> Map.get(metas, :points) end)
    |> Enum.all?(&(not is_nil(&1)))
  end
end
