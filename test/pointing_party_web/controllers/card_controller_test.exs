defmodule PointingPartyWeb.CardControllerTest do
  use PointingPartyWeb.ConnCase

  @username "test_user"

  describe "authenticated user" do
    setup %{conn: conn} do
      auth_conn = Plug.Test.init_test_session(conn, username: @username)
      {:ok, %{conn: auth_conn}}
    end

    test "GET /cards", %{conn: conn} do
      conn = get(conn, "/cards")
      assert html_response(conn, 200) =~ "Start the Party!"
    end
  end

  describe "unauthenticated user" do
    test "GET / cards redirects to the log in page", %{conn: conn} do
      conn = get(conn, "/cards")
      assert redirected_to(conn) =~ "/login"
    end
  end
end
