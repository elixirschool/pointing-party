defmodule PointingParty.Card do
  use Ecto.Schema
  import Ecto.Changeset
  alias PointingParty.Repo
  alias PointingParty.Card

  schema "cards" do
    field :description, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:title, :description])
    |> validate_required([:title, :description])
  end

  def get!(id) do
    Repo.get!(Card, id)
  end
end
