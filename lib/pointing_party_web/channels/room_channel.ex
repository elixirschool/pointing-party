defmodule PointingPartyWeb.RoomChannel do
  use PointingPartyWeb, :channel

  alias PointingPartyWeb.Presence

  def join("room:lobby", _payload, socket) do
    send(self(), :after_join)

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    push(socket, "presence_state", Presence.list(socket))
    {:ok, _} = Presence.track(socket, socket.assigns.username, %{})

    {:noreply, socket}
  end

  def handle_in("user_estimated", %{"points" => points}, socket) do
    Presence.update(socket, socket.assigns.username, fn old -> Map.put(old, :points, points) end)

    {:noreply, socket}
  end
end
