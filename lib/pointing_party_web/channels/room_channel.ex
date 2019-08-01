defmodule PointingPartyWeb.RoomChannel do
  use PointingPartyWeb, :channel

  alias PointingParty.Card
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
      finalize_voting(socket)
    end

    {:noreply, socket}
  end

  def handle_in("finalized_points", %{"points" => points}, socket) do
    updated_socket = save_vote_next_card(points, socket)
    broadcast!(updated_socket, "new_card", %{card: current_card(updated_socket)})
    {:reply, :ok, updated_socket}
  end

  def handle_in("start_pointing", _params, socket) do
    updated_socket = initialize_state(socket)
    broadcast!(updated_socket, "new_card", %{card: current_card(updated_socket)})
    {:reply, :ok, updated_socket}
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

  defp finalize_voting(socket) do
    current_users = Presence.list(socket)

    {event, points} =
      case winning_vote(current_users) do
        top_two when is_list(top_two) -> {"tie", top_two}
        winner -> {"winner", winner}
      end

    broadcast!(socket, event, %{points: points})
  end

  defp initialize_state(%{assigns: %{cards: _cards}} = socket), do: socket
  defp initialize_state(socket) do
    [first | cards] = Card.cards()

    socket
    |> assign(:points, Card.points_range())
    |> assign(:unvoted, cards)
    |> assign(:current, first)
  end

  defp save_vote_next_card(points, socket) do
    latest_card =
      socket.assigns
      |> Map.get(:current)
      |> Map.put(:points, points)

    {next, remaining} =
      socket.assigns
      |> Map.get(:unvoted)
      |> List.pop_at(0)

    socket
    |> assign(:unvoted, remaining)
    |> assign(:current, next)
    |> assign(:voted, [latest_card | socket.assigns[:voted]])
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
