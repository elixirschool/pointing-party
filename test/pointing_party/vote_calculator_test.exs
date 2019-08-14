defmodule PointingParty.VoteCalculatorTest do
  use ExUnit.Case, async: true

   @users_with_winner %{
    "sean" => %{metas: [%{points: 1}]},
    "michael" => %{metas: [%{points: 3}]},
    "sophie" => %{metas: [%{points: 3}]}
   }

  @users_with_tie %{
   "sean" => %{metas: [%{points: 1}]},
   "michael" => %{metas: [%{points: 2}]},
   "sophie" => %{metas: [%{points: 3}]}
  }

  test "calculate_votes/1 calculates when there is a winner" do
    {"winner", 3} = PointingParty.VoteCalculator.calculate_votes(@users_with_winner)
  end

  test "calculate_votes/1 calculates when there is a tie" do
    {"tie", [1,2]} = PointingParty.VoteCalculator.calculate_votes(@users_with_tie)
  end
end
