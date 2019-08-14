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

  def handle_in("user_estimated", %{"points" => points}, socket) do
    # update votes for user presence
    # calculate votes if everyone voted with the help of the VoteCalculator
    # broadcast the 'winner'/'tie' event with a payload of %{points: points}
    {:noreply, socket}
  end

  def handle_in("finalized_points", %{"points" => points}, socket) do
    # update state by setting the current card to the next card
    # broadcast the "new_card" message with a payload of %{card: new_current_card}
    {:reply, :ok, socket}
  end

  def handle_in("start_pointing", _params, socket) do
    updated_socket = initialize_state(socket)
    # broadcast the "new_card" message with a payload of %{card: current_card}
    {:reply, :ok, updated_socket}
  end

  defp initialize_state(%{assigns: %{cards: _cards}} = socket), do: socket
  defp initialize_state(socket) do
    [first | cards] = Card.cards()

    socket
    |> assign(:unvoted, cards)
    |> assign(:current, first)
  end
end
