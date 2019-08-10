defmodule PointingPartyWeb.CardLive do
  use Phoenix.LiveView

  alias PointingParty.{Card, VoteCalculator}

  def render(assigns) do
    Phoenix.View.render(PointingPartyWeb.CardView, "index.html", assigns)
  end

  def mount(%{username: _username}, socket) do
    {:ok, assign(socket, initial_state())}
  end

  ## Helper Methods ##

  defp initial_state do
    [
      pointing: false,
      current_card: nil,
      remaining_cards: [],
      outcome: nil,
      results: nil,
      completed_cards: [],
      users: []
    ]
  end

  defp get_next_card(cards) do
    List.pop_at(cards, 0)
    # returns {next_card, remaining_cards}
  end

  defp everyone_voted?(users) do
    users
    |> Enum.map(fn {_username, %{metas: [metas]}} -> Map.get(metas, :points) end)
    |> Enum.all?(&(not is_nil(&1)))
  end

  defp calculate_story_points(users) do
    VoteCalculator.calculate_votes(users)
    # returns {outcome, results}
    # ex - {"winner", 3} or {"tie", [3, 5]}
  end

  defp finalize_pointing_round(outcome, results, %{assigns: %{current_card: current_card}} = socket) do
    updated_card = save_card_points(current_card, results)

    socket
    |> assign(:current_card, updated_card)
    |> assign(:outcome, outcome)
    |> assign(:results, results)
  end

  defp save_card_points(card, points) do
    Map.put(card, :points, points)
  end

  defp reset_state_for_next_card(%{assigns: %{cards: cards, current_card: current_card, completed_cards: completed_cards}} = socket) do
    {next_card, remaining_cards} = get_next_card(cards)

    socket
    |> assign(:current_card, next_card)
    |> assign(:remaining_cards, remaining_cards)
    |> assign(:completed_cards, [current_card | socket.assigns[:completed_cards]])
    |> assign(:outcome, nil)
    |> assign(:results, nil)
  end
end
