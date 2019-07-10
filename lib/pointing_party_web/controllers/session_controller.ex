defmodule PointingPartyWeb.SessionController do
  use PointingPartyWeb, :controller
  alias PointingParty.User

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, params) do
    changeset = User.changeset(%User{}, params["user"])
    if changeset.valid? do
      user =  Ecto.Changeset.apply_changes(changeset)
      put_session(conn, :username, user.username)
      |> redirect(to: "/cards") |> halt()
    else
      changeset = %{changeset | action: :insert}
      render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, _params) do
    clear_session(conn)
    |> redirect(to: "/login") |> halt()
  end
end
