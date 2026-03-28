defmodule JuntosWeb.Router do
  use JuntosWeb, :router
  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {JuntosWeb.Layouts, :root}
    plug :put_layout, html: {JuntosWeb.Layouts, :app}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", JuntosWeb do
    pipe_through :browser

    get "/", PageController, :home

    sign_in_route(
      register_path: "/register",
      reset_path: "/reset",
      overrides: [JuntosWeb.AuthOverrides],
      auth_routes_prefix: "/auth"
    )

    sign_out_route(AuthController)
    auth_routes(AuthController, Juntos.Accounts.User)
    reset_route([])

    ash_authentication_live_session :authenticated,
      layout: {JuntosWeb.Layouts, :app},
      on_mount: [{JuntosWeb.RequireAuth, :default}] do
      live "/dashboard", DashboardLive
    end

    ash_authentication_live_session :public,
      layout: {JuntosWeb.Layouts, :app} do
      live "/tictactoe", TictactoeLive
      live "/:slug", ConferenceLive
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", JuntosWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:juntos, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: JuntosWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
