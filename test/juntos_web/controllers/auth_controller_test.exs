defmodule JuntosWeb.AuthControllerTest do
  use JuntosWeb.ConnCase, async: true

  describe "sign_out/2" do
    test "clears session and redirects to home", %{conn: conn} do
      user = create_user()

      result =
        conn
        |> log_in_user(user)
        |> get(~p"/sign-out")

      assert redirected_to(result) == ~p"/"
    end

    test "redirects to home even without a session", %{conn: conn} do
      result = get(conn, ~p"/sign-out")
      assert redirected_to(result) == ~p"/"
    end
  end

  describe "success/4" do
    test "stores user in session and redirects to home", %{conn: conn} do
      user = create_user()
      {:ok, token, _claims} = AshAuthentication.Jwt.token_for_user(user)
      user_with_token = Map.update!(user, :__metadata__, &Map.put(&1, :token, token))

      result =
        conn
        |> Phoenix.ConnTest.init_test_session(%{})
        |> JuntosWeb.AuthController.success(:magic_link, user_with_token, token)

      assert redirected_to(result) == ~p"/"
      assert result.assigns[:current_user] == user_with_token
    end
  end

  describe "failure/3" do
    test "sets error flash and redirects to sign-in", %{conn: conn} do
      result =
        conn
        |> Phoenix.ConnTest.init_test_session(%{})
        |> Phoenix.Controller.fetch_flash([])
        |> JuntosWeb.AuthController.failure(:magic_link, :invalid_token)

      assert redirected_to(result) == ~p"/sign-in"
      assert result.assigns.flash["error"] =~ "Invalid"
    end
  end
end
