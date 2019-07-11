defmodule PointingParty.Card do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
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

  def first do
    Card
    |> first
    |> Repo.one()
  end
end
