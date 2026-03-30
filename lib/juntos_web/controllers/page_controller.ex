defmodule JuntosWeb.PageController do
  use JuntosWeb, :controller

  def home(conn, _params) do
    render(conn, :home, current_user: conn.assigns[:current_user])
  end
end
