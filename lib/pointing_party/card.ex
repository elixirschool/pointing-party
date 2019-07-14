defmodule PointingParty.Card do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias PointingParty.Repo
  alias PointingParty.Card

  def points_range, do: [0, 1, 3, 5]

  schema "cards" do
    field :description, :string
    field :title, :string
    field :points, :integer

    timestamps()
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:title, :description, :points])
    |> validate_required([:title, :description])
    |> validate_inclusion(:points, Card.points_range)
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
