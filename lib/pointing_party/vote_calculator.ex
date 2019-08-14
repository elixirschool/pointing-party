defmodule PointingParty.VoteCalculator do
  def calculate_votes(users) do
    case winning_vote(users) do
      top_two when is_list(top_two) -> {"tie", top_two}
      winner -> {"winner", winner}
    end
  end

  def winning_vote(users) do
    initial_score_card()
    |> get_points(users)
    |> calculate_vote_ratios()
    |> calculate_majority()
    |> handle_tie()
  end

  def initial_score_card do
    %{votes: nil, calculated_votes: nil, majority: nil}
  end

  defp get_points(score_card, users) do
    votes =
      users
      |> Enum.map(fn {_username, %{metas: [%{points: points}]}} ->
        points
      end)

    update_score_card(score_card, :votes, votes)
  end

  defp calculate_vote_ratios(%{votes: votes} = score_card) do
    calculated_votes =
      Enum.reduce(votes, %{}, fn vote, acc ->
        acc
        |> Map.get_and_update(vote, &{&1, (&1 || 0) + 1})
        |> elem(1)
      end)

    update_score_card(score_card, :calculated_votes, calculated_votes)
  end

  defp calculate_majority(score_card) do
    total_votes = length(score_card.votes)
    majority_share = (total_votes / 2) |> Float.floor()

    majority =
      Enum.reduce_while(score_card.calculated_votes, nil, fn {point, vote_count}, _acc ->
        if vote_count == total_votes or rem(vote_count, total_votes) > majority_share do
          {:halt, point}
        else
          {:cont, nil}
        end
      end)

    update_score_card(score_card, :majority, majority)
  end

  defp handle_tie(%{majority: nil, calculated_votes: calculated_votes}) do
    calculated_votes
    |> Enum.sort_by(&elem(&1, 1))
    |> Enum.take(2)
    |> Enum.map(&elem(&1, 0))
  end

  defp handle_tie(%{majority: majority}), do: majority

  defp update_score_card(score_card, key, value) do
    Map.put(score_card, key, value)
  end
end
