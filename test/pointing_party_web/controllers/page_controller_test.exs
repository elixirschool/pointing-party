defmodule PointingPartyWeb.PageControllerTest do
  use PointingPartyWeb.ConnCase

  @username "test_user"

  describe "authenticated user" do
    setup  %{conn: conn} do
      conn = Plug.Conn.assign(conn, :username, @username)
      {:ok, %{conn: conn}}
    end

    test "GET / renders the page with log out link", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "Log Out"
    end
  end

  describe "unauthenticated user" do
    test "GET / renders the page with log in link", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "Log In"
    end
  end
end
