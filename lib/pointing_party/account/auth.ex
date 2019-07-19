defmodule PointingParty.Account.Auth do
  alias PointingParty.Account

  def login(params) do
    Account.create(params)
  end
end
