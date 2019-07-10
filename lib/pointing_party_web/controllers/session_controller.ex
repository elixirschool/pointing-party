defmodule PointingPartyWeb.SessionController do
  use PointingPartyWeb, :controller
  alias PointingParty.Account.Auth
  alias PointingParty.Account

  def new(conn, _params) do
    changeset = Account.changeset(%Account{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, params) do
    case Auth.login(params["account"]) do
      {:ok, account} ->
        put_session(conn, :username, account.username)
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
