defmodule PointingPartyWeb.CardLive do
  use Phoenix.LiveView

  alias PointingParty.{Card, VoteCalculator}

  def render(assigns) do
    # render the LiveView template here
  end

  def mount(%{username: username}, socket) do
    {:ok, assign(socket, initial_state(username))}
  end

  ## Helper Methods ##

  defp initial_state(username) do
    [
      current_card: nil,
      outcome: nil,
      is_pointing: false,
      remaining_cards: [],
      completed_cards: [],
      point_tally: nil,
      users: [],
      username: username
    ]
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
    |> assign(:completed_cards, [latest_card | socket.assigns[:completed_cards]])
  end
end
