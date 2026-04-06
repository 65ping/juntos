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
      <header class="sticky top-0 z-50 px-5 sm:px-8 py-0 flex items-center justify-between border-b border-stone-200 dark:border-stone-700/60 glass-card rounded-none h-14">
        <a href="/" class="flex items-center gap-1.5 group" aria-label="Juntos home">
          <span
            style="font-family: var(--font-display);"
            class="text-xl text-stone-900 dark:text-stone-100 tracking-tight group-hover:text-brand-800 dark:group-hover:text-brand-400 transition-colors duration-150"
          >
            Juntos
          </span>
          <span
            aria-hidden="true"
            class="w-1.5 h-1.5 rounded-full bg-brand-700 dark:bg-brand-400 mb-0.5 opacity-80 group-hover:opacity-100 transition-opacity duration-150"
          >
          </span>
        </a>

        <nav class="flex items-center gap-1 sm:gap-2" aria-label="Main navigation">
          <.theme_toggle />
          <%= if @current_user do %>
            <div class="hidden sm:flex items-center gap-0.5 ml-1">
              <a
                href={~p"/conferences"}
                class="text-sm text-stone-500 dark:text-stone-400 hover:text-stone-900 dark:hover:text-stone-100 transition-colors duration-150 px-2.5 py-1.5 rounded-lg hover:bg-stone-100/80 dark:hover:bg-stone-800/60"
              >
                Browse
              </a>
              <a
                href={~p"/dashboard"}
                class="text-sm text-stone-600 dark:text-stone-300 hover:text-stone-900 dark:hover:text-stone-100 transition-colors duration-150 px-2.5 py-1.5 rounded-lg hover:bg-stone-100/80 dark:hover:bg-stone-800/60"
              >
                Dashboard
              </a>
            </div>
            <div
              class="w-px h-4 bg-stone-200 dark:bg-stone-700 hidden sm:block mx-1"
              aria-hidden="true"
            />
            <a
              href={~p"/profile"}
              class="hidden sm:inline-flex items-center justify-center w-7 h-7 rounded-full bg-brand-100 dark:bg-brand-900/60 text-brand-800 dark:text-brand-400 text-xs font-semibold hover:bg-brand-200 dark:hover:bg-brand-800/80 transition-colors duration-150"
              aria-label="Your profile"
              title="Profile"
            >
              {String.first(to_string(@current_user.email)) |> String.upcase()}
            </a>
            <a
              href={~p"/sign-out"}
              class="text-xs text-stone-400 dark:text-stone-500 hover:text-stone-600 dark:hover:text-stone-300 transition-colors duration-150 px-2 py-1.5 rounded-lg hover:bg-stone-100/80 dark:hover:bg-stone-800/60"
            >
              Sign out
            </a>
          <% else %>
            <a
              href={~p"/conferences"}
              class="hidden sm:inline-flex text-sm text-stone-500 dark:text-stone-400 hover:text-stone-900 dark:hover:text-stone-100 transition-colors duration-150 px-2.5 py-1.5 rounded-lg hover:bg-stone-100/80 dark:hover:bg-stone-800/60 ml-1"
            >
              Browse
            </a>
            <a
              href={~p"/sign-in"}
              class="inline-flex items-center gap-1.5 px-4 py-1.5 text-sm font-medium text-white bg-brand-800 dark:bg-brand-700 hover:bg-brand-900 dark:hover:bg-brand-600 rounded-full transition-colors duration-150 ml-1"
            >
              Sign in
            </a>
          <% end %>
        </nav>
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
    <div
      class="relative flex items-center bg-stone-100 dark:bg-stone-800 rounded-full p-0.5"
      role="group"
      aria-label="Theme selector"
    >
      <div class="absolute top-0.5 bottom-0.5 w-[calc(33.333%-2px)] rounded-full bg-white dark:bg-stone-600 shadow-sm left-[2px] [[data-theme=light]_&]:left-[calc(33.333%+1px)] [[data-theme=dark]_&]:left-[calc(66.667%)] transition-[left] duration-200" />
      <button
        class="relative flex items-center justify-center p-1.5 w-8 cursor-pointer text-stone-500 dark:text-stone-400 hover:text-stone-700 dark:hover:text-stone-200 transition-colors"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
        aria-label="Use system theme"
        title="System"
      >
        <.icon name="hero-computer-desktop-micro" class="size-3.5" />
      </button>
      <button
        class="relative flex items-center justify-center p-1.5 w-8 cursor-pointer text-stone-500 dark:text-stone-400 hover:text-stone-700 dark:hover:text-stone-200 transition-colors"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
        aria-label="Use light theme"
        title="Light"
      >
        <.icon name="hero-sun-micro" class="size-3.5" />
      </button>
      <button
        class="relative flex items-center justify-center p-1.5 w-8 cursor-pointer text-stone-500 dark:text-stone-400 hover:text-stone-700 dark:hover:text-stone-200 transition-colors"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
        aria-label="Use dark theme"
        title="Dark"
      >
        <.icon name="hero-moon-micro" class="size-3.5" />
      </button>
    </div>
    """
  end

  @doc """
  Renders the application footer.
  """
  def footer(assigns) do
    ~H"""
    <footer class="border-t border-stone-200 dark:border-stone-700/60 bg-stone-50 dark:bg-stone-900/40">
      <div class="max-w-5xl mx-auto px-6 py-12">
        <div class="flex flex-col sm:flex-row items-start justify-between gap-10">
          <div class="space-y-3">
            <div class="flex items-center gap-1.5">
              <span
                style="font-family: var(--font-display);"
                class="text-lg text-stone-700 dark:text-stone-300"
              >
                Juntos
              </span>
              <span
                aria-hidden="true"
                class="w-1.5 h-1.5 rounded-full bg-brand-700 dark:bg-brand-400 mb-0.5 opacity-70"
              >
              </span>
            </div>
            <p class="text-xs text-stone-400 dark:text-stone-500 max-w-[16rem] leading-relaxed">
              The conference platform for developers who build communities worth gathering around.
            </p>
          </div>

          <div class="flex flex-wrap gap-10 text-sm">
            <div class="space-y-3">
              <p class="text-xs font-semibold uppercase tracking-widest text-stone-400 dark:text-stone-500">
                Platform
              </p>
              <nav
                class="flex flex-col gap-2 text-stone-500 dark:text-stone-400"
                aria-label="Platform links"
              >
                <a
                  href={~p"/conferences"}
                  class="hover:text-brand-800 dark:hover:text-brand-400 transition-colors"
                >
                  Browse conferences
                </a>
                <a
                  href={~p"/sign-in"}
                  class="hover:text-brand-800 dark:hover:text-brand-400 transition-colors"
                >
                  Sign in
                </a>
                <a
                  href={~p"/sign-in"}
                  class="hover:text-brand-800 dark:hover:text-brand-400 transition-colors"
                >
                  Organize an event
                </a>
              </nav>
            </div>
            <div class="space-y-3">
              <p class="text-xs font-semibold uppercase tracking-widest text-stone-400 dark:text-stone-500">
                Legal
              </p>
              <nav
                class="flex flex-col gap-2 text-stone-500 dark:text-stone-400"
                aria-label="Legal links"
              >
                <a href="#" class="hover:text-brand-800 dark:hover:text-brand-400 transition-colors">
                  Terms
                </a>
                <a href="#" class="hover:text-brand-800 dark:hover:text-brand-400 transition-colors">
                  Privacy
                </a>
                <a href="#" class="hover:text-brand-800 dark:hover:text-brand-400 transition-colors">
                  Contact
                </a>
              </nav>
            </div>
          </div>
        </div>

        <div class="mt-10 pt-6 border-t border-stone-200 dark:border-stone-700/60 flex items-center justify-center">
          <p class="text-xs text-stone-400 dark:text-stone-600">
            &copy; {Date.utc_today().year} Juntos. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
    """
  end
end
