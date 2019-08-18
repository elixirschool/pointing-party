defmodule PointingPartyWeb.RoomChannel do
  use PointingPartyWeb, :channel

  alias PointingParty.{Card, VoteCalculator}
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
    Presence.update(socket, socket.assigns.username, &(Map.put(&1, :points, points)))

    if everyone_voted?(socket) do
      calculate_story_points(socket)
    end

    {:noreply, socket}
  end

  def handle_in("next_card", %{"points" => points}, socket) do
    updated_socket = save_vote_next_card(points, socket)
    broadcast!(updated_socket, "new_card", %{card: current_card(updated_socket)})
    {:reply, :ok, updated_socket}
  end

  def handle_in("start_pointing", _params, socket) do
    updated_socket = initialize_state(socket)
    broadcast!(updated_socket, "new_card", %{card: current_card(updated_socket)})
    {:reply, :ok, updated_socket}
  end

  intercept ["new_card"]

  def handle_out("new_card", payload, socket) do
    Presence.update(socket, socket.assigns.username, &(Map.put(&1, :points, nil)))
    push(socket, "new_card", payload)
    {:noreply, socket}
  end

  defp current_card(socket) do
    socket.assigns
    |> Map.get(:current)
    |> Map.from_struct()
    |> Map.drop([:__meta__])
  end

  defp everyone_voted?(socket) do
    socket
    |> Presence.list()
    |> Enum.map(fn {_username, %{metas: [metas]}} -> Map.get(metas, :points) end)
    |> Enum.all?(&(not is_nil(&1)))
  end

  defp calculate_story_points(socket) do
    current_users = Presence.list(socket)

    {event, points} = VoteCalculator.calculate_votes(current_users)
    broadcast!(socket, event, %{points: points})
  end

  defp initialize_state(%{assigns: %{cards: _cards}} = socket), do: socket

  defp initialize_state(socket) do
    [first | cards] = Card.cards()

    socket
    |> assign(:unvoted, cards)
    |> assign(:current, first)
  end

  defp save_vote_next_card(points, socket) do
    # save the points on the card
    latest_card =
      socket.assigns
      |> Map.get(:current)
      |> Map.put(:points, points)

    # fetch the next card from the list of cards
    {next, remaining} =
      socket.assigns
      |> Map.get(:unvoted)
      |> List.pop_at(0)

    # update socket state by moving the current card into `voted` and the next card into `current_card`
    socket
    |> assign(:unvoted, remaining)
    |> assign(:current, next)
    |> assign(:voted, [latest_card | socket.assigns[:voted]])
  end
end
