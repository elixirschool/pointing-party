defmodule PointingPartyWeb.CardControllerTest do
  use PointingPartyWeb.ConnCase
  import PointingParty.Factory

  @username "test_user"

  describe "authenticated user" do
    setup  %{conn: conn} do
      conn = conn
      |> Plug.Test.init_test_session(username: @username)
      {:ok, %{conn: conn}}
    end

    test "GET /cards", %{conn: conn} do
      insert(:card)
      conn = get(conn, "/cards")
      assert html_response(conn, 200) =~ "Ticket Title0"
    end
  end

  describe "unauthenticated user" do
    test "GET / cards redirects to the log in page", %{conn: conn} do
      conn = get(conn, "/cards")
      assert redirected_to(conn) =~ "/login"
    end
  end
end
