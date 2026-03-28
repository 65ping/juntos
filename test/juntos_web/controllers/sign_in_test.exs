defmodule JuntosWeb.SignInTest do
  use JuntosWeb.ConnCase, async: true

  describe "GET /sign-in" do
    test "renders the sign-in page", %{conn: conn} do
      conn = get(conn, ~p"/sign-in")
      assert html_response(conn, 200) =~ "Juntos"
    end
  end

  describe "GET /register" do
    test "renders the register page", %{conn: conn} do
      conn = get(conn, ~p"/register")
      assert html_response(conn, 200) =~ "Juntos"
    end
  end
end
