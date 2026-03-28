defmodule JuntosWeb.RequireAuth do
  @moduledoc """
  on_mount hook that redirects unauthenticated users to sign-in.
  """
  import Phoenix.LiveView

  def on_mount(:default, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: "/sign-in")}
    end
  end
end
