defmodule PointingPartyWeb.RoomChannel do
  use PointingPartyWeb, :channel

  alias PointingParty.Card

  def join("room:lobby", _payload, socket) do
    send(self(), :after_join)

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    # handle Presence listing and tracking here

    {:noreply, socket}
  end

  def handle_in("start_pointing", _params, socket) do
    updated_socket = initialize_state(socket)
    # broadcast the "new_card" message with a payload of %{card: current_card}

    {:reply, :ok, updated_socket}
  end

  def handle_in("user_estimated", %{"points" => points}, socket) do
    # update votes for user presence
    # if everyone voted, calculate story point estimate with the help of the VoteCalculator
    # broadcast the 'winner'/'tie' event with a payload of %{points: points}

    {:noreply, socket}
  end

  def handle_in("next_card", %{"points" => points}, socket) do
    save_vote_next_card(points, socket)
    # broadcast the "new_card" message with a payload of %{card: new_current_card}

    {:reply, :ok, socket}
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
