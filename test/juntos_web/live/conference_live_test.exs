defmodule JuntosWeb.ConferenceLiveTest do
  use JuntosWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Juntos.Core.Conference

  setup do
    user = create_user()
    conference = create_conference(user, %{name: "ElixirConf 2026", location: "Austin, TX"})
    %{user: user, conference: conference}
  end

  describe "mount" do
    test "renders the conference hero with name and location", %{conn: conn, conference: conf} do
      {:ok, _view, html} = live(conn, ~p"/#{conf.slug}")

      assert html =~ "ElixirConf 2026"
      assert html =~ "Austin, TX"
      assert html =~ "Draft"
    end

    test "renders description when present", %{conn: conn, user: user} do
      conf = create_conference(user, %{name: "WithDesc", description: "A great conf"})

      {:ok, _view, html} = live(conn, ~p"/#{conf.slug}")

      assert html =~ "A great conf"
    end

    test "renders formatted start date when starts_at is set", %{conn: conn, user: user} do
      conf = create_conference(user, %{name: "DatedConf", starts_at: ~U[2026-06-15 00:00:00Z]})

      {:ok, _view, html} = live(conn, ~p"/#{conf.slug}")

      assert html =~ "June 15, 2026"
    end

    test "redirects to home for unknown slug", %{conn: conn} do
      assert {:error, {:live_redirect, %{to: "/"}}} = live(conn, ~p"/no-such-conference")
    end

    test "always renders the ConferenceSchedule component", %{conn: conn, conference: conf} do
      {:ok, _view, html} = live(conn, ~p"/#{conf.slug}")

      assert html =~ "ConferenceSchedule"
    end
  end

  describe "get_ticket event" do
    test "shows a coming soon flash", %{conn: conn, conference: conf} do
      tier =
        Ash.create!(
          Juntos.Core.TicketTier,
          %{name: "General", price_cents: 9900, conference_id: conf.id},
          action: :create
        )

      {:ok, view, _html} = live(conn, ~p"/#{conf.slug}")

      render_hook(view, "get_ticket", %{"tier_id" => tier.id})

      assert render(view) =~ "coming soon"
    end
  end

  describe "status badge" do
    test "shows correct label for each status", %{conn: conn, user: user} do
      for {status, label} <- [
            cfp_open: "CFP Open",
            cfp_closed: "CFP Closed",
            scheduled: "Coming Soon",
            complete: "Complete"
          ] do
        conf =
          Ash.Seed.seed!(Conference, %{
            name: "Conf",
            slug: "conf-#{status}",
            status: status,
            organizer_id: user.id
          })

        {:ok, _view, html} = live(conn, ~p"/#{conf.slug}")
        assert html =~ label, "expected status #{status} to render label #{label}"
      end
    end
  end
end
