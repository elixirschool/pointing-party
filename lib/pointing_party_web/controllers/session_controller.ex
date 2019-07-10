defmodule PointingPartyWeb.SessionController do
  use PointingPartyWeb, :controller
  alias PointingParty.User

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, params) do
    case User.create(params["user"]) do
      {:ok, user} ->
        put_session(conn, :username, user.username)
        |> redirect(to: "/cards") |> halt()
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, _params) do
    clear_session(conn)
    |> redirect(to: "/login") |> halt()
  end
end
