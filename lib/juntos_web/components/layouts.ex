defmodule JuntosWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use JuntosWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_user, :map, default: nil
  attr :inner_content, :any, default: nil

  def app(assigns) do
    ~H"""
    <div class="min-h-screen flex flex-col">
      <header class="sticky top-0 z-50 px-6 py-4 flex items-center justify-between border-b border-stone-200 dark:border-stone-800 glass-card rounded-none">
        <a href="/" class="flex items-center gap-2 group">
          <span
            style="font-family: var(--font-display);"
            class="text-xl text-stone-900 dark:text-stone-100 tracking-tight"
          >
            Juntos
          </span>
          <span class="w-1.5 h-1.5 rounded-full bg-amber-500 mb-0.5 group-hover:bg-amber-400 transition-colors">
          </span>
        </a>

        <div class="flex items-center gap-3">
          <.theme_toggle />
          <%= if @current_user do %>
            <a
              href={~p"/dashboard"}
              class="text-sm font-medium text-stone-600 dark:text-stone-300 hover:text-stone-900 dark:hover:text-stone-100 transition-colors px-3 py-1.5 rounded-md hover:bg-stone-100 dark:hover:bg-stone-800"
            >
              Dashboard
            </a>
            <a
              href={~p"/sign-out"}
              class="text-sm font-medium text-stone-500 dark:text-stone-400 hover:text-stone-700 dark:hover:text-stone-200 transition-colors px-3 py-1.5 rounded-md hover:bg-stone-100 dark:hover:bg-stone-800"
            >
              Sign out
            </a>
          <% else %>
            <a
              href={~p"/sign-in"}
              class="text-sm font-medium text-white bg-amber-600 hover:bg-amber-500 transition-colors px-4 py-2 rounded-md shadow-sm"
            >
              Sign in
            </a>
          <% end %>
        </div>
      </header>

      <main class="flex-1">
        {@inner_content}
      </main>

      <.footer />
    </div>
    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
        aria-label="Use system theme"
        title="System"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
        aria-label="Use light theme"
        title="Light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
        aria-label="Use dark theme"
        title="Dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end

  @doc """
  Renders the application footer.
  """
  def footer(assigns) do
    ~H"""
    <footer class="border-t border-stone-200 dark:border-stone-800 bg-stone-50 dark:bg-stone-900/50">
      <div class="max-w-4xl mx-auto px-6 py-10">
        <div class="flex flex-col sm:flex-row items-center justify-between gap-6">
          <div class="flex items-center gap-2">
            <span
              style="font-family: var(--font-display);"
              class="text-lg text-stone-700 dark:text-stone-300"
            >
              Juntos
            </span>
            <span class="w-1.5 h-1.5 rounded-full bg-amber-500"></span>
          </div>

          <nav class="flex items-center gap-6 text-sm text-stone-500 dark:text-stone-400">
            <a href="/" class="hover:text-stone-900 dark:hover:text-stone-100 transition-colors">
              Home
            </a>
            <a
              href="/sign-in"
              class="hover:text-stone-900 dark:hover:text-stone-100 transition-colors"
            >
              Sign in
            </a>
          </nav>
        </div>

        <div class="mt-8 pt-6 border-t border-stone-200 dark:border-stone-800 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-stone-400 dark:text-stone-500">
          <p>&copy; {Date.utc_today().year} Juntos. All rights reserved.</p>
          <div class="flex items-center gap-4">
            <a href="#" class="hover:text-stone-600 dark:hover:text-stone-300 transition-colors">
              Terms
            </a>
            <a href="#" class="hover:text-stone-600 dark:hover:text-stone-300 transition-colors">
              Privacy
            </a>
            <a href="#" class="hover:text-stone-600 dark:hover:text-stone-300 transition-colors">
              Contact
            </a>
          </div>
        </div>
      </div>
    </footer>
    """
  end
end
