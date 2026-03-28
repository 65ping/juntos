defmodule JuntosWeb.E2E.ConferenceTest do
  @moduledoc """
  Happy-path E2E tests for conference creation on the dashboard.

  Verifies the full browser flow: authenticated user opens the new-conference
  form, fills in the name, submits, and sees the conference listed.
  """

  use JuntosWeb.E2ECase

  setup %{conn: conn} do
    user = create_user()
    conn = log_in_user(conn, user)
    {:ok, conn: conn, user: user}
  end

  @tag :e2e
  test "shows empty state for a new user", %{conn: conn} do
    conn
    |> visit(~p"/dashboard")
    |> assert_has("h1", text: "My Conferences")
    |> assert_has("p", text: "No conferences yet")
  end

  @tag :e2e
  test "creates a conference and shows it in the list", %{conn: conn} do
    conn
    |> visit(~p"/dashboard")
    |> click_button("New conference")
    |> fill_in("Conference name", with: "ElixirConf 2026")
    |> click_button("Create conference")
    |> assert_has("a", text: "ElixirConf 2026")
  end

  @tag :e2e
  test "shows existing conferences on load", %{conn: conn, user: user} do
    create_conference(user, %{name: "Existing Conf"})

    conn
    |> visit(~p"/dashboard")
    |> assert_has("a", text: "Existing Conf")
  end

  @tag :e2e
  test "cancelling the new conference form hides it", %{conn: conn} do
    conn
    |> visit(~p"/dashboard")
    |> click_button("New conference")
    |> assert_has("h2", text: "New Conference")
    |> click_button("Cancel")
    |> refute_has("h2", text: "New Conference")
  end
end
