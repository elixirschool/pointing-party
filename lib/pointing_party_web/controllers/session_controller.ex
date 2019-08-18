defmodule PointingPartyWeb.SessionController do
  use PointingPartyWeb, :controller

  alias PointingParty.{Account, Account.Auth}

  def new(conn, _params) do
    changeset = Account.changeset(%Account{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, params) do
    case Auth.login(params["account"]) do
      {:ok, %{username: username}} ->
        conn
        |> put_session(:username, username)
        |> redirect(to: "/cards")
        |> halt()

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: "/login")
    |> halt()
  end
end
