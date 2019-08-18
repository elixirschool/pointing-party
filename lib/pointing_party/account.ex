defmodule PointingParty.Account do
  use Ecto.Schema

  import Ecto.Changeset

  alias PointingParty.Account

  schema "accounts" do
    field :username, :string
  end

  def create(attrs) do
    changeset = changeset(%Account{}, attrs)

    if changeset.valid? do
      account = apply_changes(changeset)
      {:ok, account}
    else
      {:error, %{changeset | action: :insert}}
    end
  end

  def changeset(account, attrs \\ %{}) do
    account
    |> cast(attrs, [:username])
    |> validate_required([:username])
  end
end
