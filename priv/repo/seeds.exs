# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PointingParty.Repo.insert!(%PointingParty.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias PointingParty.{Card, Repo}

cards = [
  %{title: "First card", description: "This is a description of the first card."},
  %{title: "Second card", description: "This is a description of the second card."},
  %{title: "Third card", description: "This is a description of the third card."},
  %{title: "Fourth card", description: "This is a description of the fourth card."},
  %{title: "Fifth card", description: "This is a description of the fifth card."},
  %{title: "Sixth card", description: "This is a description of the sixth card."},
  %{title: "Seventh card", description: "This is a description of the seventh card."},
  %{title: "Eighth card", description: "This is a description of the eighth card."}
]

Enum.each(cards, fn card ->
  %Card{}
  |> Card.changeset(card)
  |> Repo.insert!([])
end)
