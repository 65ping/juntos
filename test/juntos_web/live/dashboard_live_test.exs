defmodule JuntosWeb.DashboardLiveTest do
  use JuntosWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "unauthenticated access" do
    test "redirects to sign-in when not logged in", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/sign-in"}}} = live(conn, ~p"/dashboard")
    end
  end

  describe "mount" do
    test "shows empty dashboard for new user", %{conn: conn} do
      user = create_user()
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/dashboard")

      assert render(view) =~ to_string(user.email)
      assert render(view) =~ "&quot;conferences&quot;:[]"
    end

    test "lists the user's own conferences", %{conn: conn} do
      user = create_user()
      _conf = create_conference(user, %{name: "ElixirConf 2026", location: "Austin, TX"})
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/dashboard")

      assert render(view) =~ "ElixirConf 2026"
      assert render(view) =~ "Austin, TX"
    end

    test "does not show another user's conferences", %{conn: conn} do
      owner = create_user()
      other = create_user()
      _conf = create_conference(owner, %{name: "OtherConf"})
      conn = log_in_user(conn, other)

      {:ok, view, _html} = live(conn, ~p"/dashboard")

      refute render(view) =~ "OtherConf"
      assert render(view) =~ "&quot;conferences&quot;:[]"
    end
  end

  describe "create_conference event" do
    test "creates a conference and displays it", %{conn: conn} do
      user = create_user()
      conn = log_in_user(conn, user)
      {:ok, view, _html} = live(conn, ~p"/dashboard")

      render_hook(view, "create_conference", %{
        "conference" => %{
          "name" => "BeamConf",
          "description" => "",
          "location" => "Berlin",
          "starts_at" => ""
        }
      })

      assert render(view) =~ "BeamConf"
      assert render(view) =~ "Berlin"
    end

    test "shows error flash when name is missing", %{conn: conn} do
      user = create_user()
      conn = log_in_user(conn, user)
      {:ok, view, _html} = live(conn, ~p"/dashboard")

      render_hook(view, "create_conference", %{
        "conference" => %{"name" => "", "description" => "", "location" => "", "starts_at" => ""}
      })

      assert render(view) =~ "Could not create conference"
    end
  end

  describe "delete_conference event" do
    test "removes the conference from the list", %{conn: conn} do
      user = create_user()
      conf = create_conference(user, %{name: "ToDelete"})
      conn = log_in_user(conn, user)
      {:ok, view, _html} = live(conn, ~p"/dashboard")

      assert render(view) =~ "ToDelete"

      render_hook(view, "delete_conference", %{"id" => conf.id})

      # LiveVue uses JSON diffs, so verify deletion via database and diff
      assert {:error, _} = Ash.get(Juntos.Core.Conference, conf.id)
      # The diff should contain a remove operation for the conference
      assert render(view) =~ "remove"
    end

    test "cannot delete another user's conference", %{conn: conn} do
      owner = create_user()
      attacker = create_user()
      conf = create_conference(owner, %{name: "Protected"})
      conn = log_in_user(conn, attacker)
      {:ok, view, _html} = live(conn, ~p"/dashboard")

      render_hook(view, "delete_conference", %{"id" => conf.id})

      assert render(view) =~ "Conference not found"
      assert Ash.get!(Juntos.Core.Conference, conf.id)
    end
  end
end
