defmodule JuntosWeb.PageController do
  use JuntosWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
