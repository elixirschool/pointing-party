defmodule PointingPartyWeb.CardLive do
  use Phoenix.LiveView

  import PointingParty.Card, only: [cards: 0]
  alias PointingPartyWeb.Presence

  def render(assigns) do
    Phoenix.View.render(PointingPartyWeb.CardView, "index.html", assigns)
  end

  def mount(%{username: username}, socket) do
    {:ok, _} = Presence.track(self(), "users", username, %{})
    users =
      "users"
      |> Presence.list()
      |> Map.keys()

    assigns = [
      party_has_started: false,
      tentative_points: 1,
      username: username,
      users: users
    ]
    {:ok, assign(socket, assigns)}
  end

  def handle_event("start_party", _, socket) do
    {:noreply, assign(socket, card: List.first(cards()), party_has_started: true)}
  end

  def handle_event("tentative_vote", %{"points" => points}, socket) do
    {:noreply, assign(socket, tentative_points: points)}
  end

  def handle_event("vote", _points, socket) do
    Presence.update(self(), "users", socket.assigns.username, &Map.put(&1, :points, socket.assigns.tentative_points))

    {:noreply, socket}
  end
end
