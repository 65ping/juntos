defmodule JuntosWeb.E2E.AuthFlowTest do
  @moduledoc """
  Happy-path E2E tests for the authentication flow.

  Tests the sign-in page UI and that protected routes redirect
  unauthenticated users.
  """

  use JuntosWeb.E2ECase

  @tag :e2e
  test "sign-in page renders with email input", %{conn: conn} do
    conn
    |> visit(~p"/sign-in")
    |> assert_has("input[type=email]")
  end

  @tag :e2e
  test "submitting the sign-in form shows confirmation", %{conn: conn} do
    conn
    |> visit(~p"/sign-in")
    |> fill_in("Email", with: "hello@example.com")
    |> submit()
    |> assert_has("[role=alert]", text: "Check your email")
  end

  @tag :e2e
  test "unauthenticated access to dashboard redirects to sign-in", %{conn: conn} do
    conn
    |> visit(~p"/dashboard")
    |> assert_path(~p"/sign-in")
  end

  @tag :e2e
  test "authenticated user can access dashboard", %{conn: conn} do
    user = create_user()

    conn
    |> log_in_user(user)
    |> visit(~p"/dashboard")
    |> assert_has("h1", text: "My Conferences")
  end
end
