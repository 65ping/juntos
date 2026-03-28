defmodule JuntosWeb.E2ECase do
  @moduledoc """
  Test case template for end-to-end browser tests using PhoenixTest.Playwright.

  Provides session helpers for authenticating users in the browser context
  by injecting a signed Plug session cookie, mirroring what the production
  auth flow does after a successful magic-link sign-in.
  """

  use ExUnit.CaseTemplate

  alias AshAuthentication.Plug.Helpers, as: AuthHelpers
  alias PhoenixTest.Playwright, as: PlaywrightTest

  using do
    quote do
      use PhoenixTest.Playwright.Case, async: false

      use JuntosWeb, :verified_routes

      import JuntosWeb.ConnCase, only: [create_user: 0, create_user: 1, create_conference: 2]
      import JuntosWeb.E2ECase
    end
  end

  @doc """
  Injects an authenticated session cookie for `user` into the Playwright browser context.

  Generates a JWT for the user, stores it in a Plug session via the same
  AshAuthentication helpers used by the real auth flow, then injects the
  resulting signed cookie so subsequent page visits are authenticated.
  """
  def log_in_user(conn, user) do
    {:ok, token, _claims} = AshAuthentication.Jwt.token_for_user(user)
    user_with_token = Map.update!(user, :__metadata__, &Map.put(&1, :token, token))

    fake_conn =
      Phoenix.ConnTest.build_conn()
      |> Phoenix.ConnTest.init_test_session(%{})
      |> AuthHelpers.store_in_session(user_with_token)

    session = Plug.Conn.get_session(fake_conn)

    PlaywrightTest.add_session_cookie(
      conn,
      [value: session],
      JuntosWeb.Endpoint.session_options()
    )
  end
end
