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

    {:ok, assign(socket, party_has_started: false, username: username, users: users)}
  end

  def handle_event("start_party", _, socket) do
    {:noreply, assign(socket, card: List.first(cards()), party_has_started: true)}
  end

  # Change HTML to use a form so we can get points?
  def handle_event("vote", _points, socket) do
    Presence.update(self(), "users", socket.assigns.username, &Map.put(&1, :points, 3))
    IO.inspect Presence.list("users")

    {:noreply, socket}
  end
end
