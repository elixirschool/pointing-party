defmodule PointingParty.Repo.Migrations.AddPointsToCards do
  use Ecto.Migration

  def change do
    alter table("cards") do
      add :points, :integer, default: 0
    end
  end
end
