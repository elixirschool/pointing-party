defmodule PointingParty.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias PointingParty.User

  schema "users" do
    field :username, :string
  end

  def create(attrs) do
    changeset = changeset(%User{}, attrs)
    if changeset.valid? do
      user =  apply_changes(changeset)
      {:ok, user}
    else
      {:error, %{changeset | action: :insert}}
    end
  end

  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:username])
    |> validate_required([:username])
  end
end
