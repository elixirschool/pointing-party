defmodule PointingParty.Factory do
  use ExMachina

  alias PointingParty.Card

  def card_factory do
    %Card{
      title: sequence("Ticket Title"),
      description: sequence("Ticket description")
    }
  end
end
