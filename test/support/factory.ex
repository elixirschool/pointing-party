defmodule PointingParty.Factory do
  use ExMachina.Ecto, repo: PointingParty.Repo
  alias PointingParty.Card

  def card_factory do
    %Card{
      title: sequence("Ticket Title"),
      description: sequence("Ticket description")
    }
  end
end
