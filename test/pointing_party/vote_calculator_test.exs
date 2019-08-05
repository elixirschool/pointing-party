defmodule PointingParty.VoteCalculatorTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  describe "calculate_votes/1" do
    setup do
      points_map = fixed_map(%{points: integer(1..5)})

      metas_map =
        fixed_map(%{
          metas: list_of(points_map, length: 1)
        })

      users = nonempty(map_of(string(:alphanumeric), metas_map))
      [users: users]
    end

    property "winning value is a list or a integer", %{users: users} do
      check all users <- users do
        {_event, winner} = PointingParty.VoteCalculator.calculate_votes(users)
        assert is_list(winner) || is_integer(winner)
      end
    end

    property "tie when winning value is a list, winner when winning value is an integer", %{users: users} do
      check all users <- users do
        {event, winner} = PointingParty.VoteCalculator.calculate_votes(users)

        cond do
          is_list(winner) ->
            assert event == "tie"

          is_integer(winner) ->
            assert event == "winner"
        end
      end
    end

    property "the winning value is not more than the highest point value", %{users: users} do
      check all users <- users do
        {_event, winner} = PointingParty.VoteCalculator.calculate_votes(users)

        max_vote =
          users
          |> Enum.map(fn {_username, %{metas: [%{points: points}]}} -> points end)
          |> Enum.max()

        cond do
          is_list(winner) ->
            assert Enum.max(winner) <= max_vote

          is_integer(winner) ->
            assert winner <= max_vote
        end
      end
    end

    property "when the winner is a list of two sorted values", %{users: users} do
      check all users <- users do
        {_event, winner} = PointingParty.VoteCalculator.calculate_votes(users)

        if is_list(winner) do
          assert length(winner) == 2

          votes = Enum.map(users, fn {_username, %{metas: [%{points: points}]}} -> points end)

          calculated_votes =
            Enum.reduce(votes, %{}, fn vote, acc ->
              value = (acc[vote] || 0) + 1
              Map.put(acc, vote, value)
            end)

          sorted =
            calculated_votes
            |> Enum.sort_by(fn ({_k, v}) -> v end)
            |> Enum.map(fn ({a, _b}) -> a end)
            |> Enum.take(2)

          assert sorted == winner
        end
      end
    end
  end
end
