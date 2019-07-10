defmodule PointingPartyWeb.Plugs.Auth do
  import Plug.Conn
  import Phoenix.Controller

  def init(default), do: default

  def call(conn, _default) do
    case authenticate(conn) do
      nil -> redirect(conn, to: "/login") |> halt()
      username -> assign(conn, :username, username)
    end
  end

  defp authenticate(conn) do
     get_session(conn, :username)
  end
end
