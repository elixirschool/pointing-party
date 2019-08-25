defmodule PointingParty.VoteCalculatorTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias PointingParty.{Card, VoteCalculator}

  # Properties
  # --------------
  # When there is a tie, the result will be a list
  # The tie list will be sorted in increasing order
  # The tie list will contain unique elements
  # The tie list will have exactly two elements
  # The tie list contains only integers
  # The tie list integers must be valid voting options
  # The greatest element in the tie list will not be greater than the highest vote
  #
  # When there is a winner, the result will be an integer
  # When there is a winner, the result will be one of the valid voting options
  # When there is a winner, it will not be greater than the highest vote
  #
  # Notes
  # --------------
  # Ties can happen when there are even or odd numbers of players
  # Winning votes can also have an even or odd number of players
  # Single-player games will always have a winner


  describe "calculate_votes/1" do
    setup do
      points_map = fixed_map(%{
        points: member_of(Card.points_range())
      })
      metas_map = fixed_map(%{
        metas: list_of(points_map, length: 1)
      })
      user_generator = nonempty(map_of(string(:alphanumeric), metas_map))

      [user_generator: user_generator]
    end

    property "calculated vote is a list or an integer", %{user_generator: user_generator} do
      check all users <- user_generator,
                {_event, winner} = VoteCalculator.calculate_votes(users),
                max_runs: 20 do
        assert is_list(winner) || is_integer(winner)
      end
    end

    property "the winning value is not more than the highest vote", %{user_generator: user_generator} do
      check all users <- user_generator,
                max_runs: 20 do
        max_vote =
          users
          |> Enum.map(fn {_username, %{metas: [%{points: points}]}} -> points end)
          |> Enum.max()

        case PointingParty.VoteCalculator.calculate_votes(users) do
          {"winner", winner} -> assert winner <= max_vote
          {"tie", [_lesser, greater]} -> assert greater <= max_vote
        end
      end
    end

    property "when there is a winner, calculated vote is a valid integer", %{user_generator: user_generator} do
      check all users <- user_generator,
                {event, winner} = PointingParty.VoteCalculator.calculate_votes(users),
                max_runs: 20 do
        if event == "winner" do
          assert winner in Card.points_range()
        end
      end
    end

    property "when there is a tie, calculated vote is a list with two sorted values", %{user_generator: user_generator} do
      check all users <- user_generator,
                {event, votes} = PointingParty.VoteCalculator.calculate_votes(users),
                max_runs: 20 do
        if event == "tie" do
          [lesser, greater] = votes

          assert lesser < greater
        end
      end
    end

    property "when there is a tie, calculated vote is a list of valid integers", %{user_generator: user_generator} do
      check all users <- user_generator,
                {event, votes} = PointingParty.VoteCalculator.calculate_votes(users),
                max_runs: 20 do
        if event == "tie" do
          assert Enum.all?(votes, fn vote -> vote in Card.points_range() end)
        end
      end
    end
  end
end
