defmodule JuntosWeb.AuthOverrides do
  use AshAuthentication.Phoenix.Overrides

  @moduledoc false
  alias AshAuthentication.Phoenix.{Components, MagicSignInLive, SignInLive}

  override SignInLive do
    set(
      :root_class,
      "min-h-screen flex flex-col items-center justify-center px-4 bg-stone-50 dark:bg-stone-950"
    )
  end

  override MagicSignInLive do
    set(
      :root_class,
      "min-h-screen flex flex-col items-center justify-center px-4 bg-stone-50 dark:bg-stone-950"
    )
  end

  override Components.Banner do
    set(:root_class, "w-full flex flex-col items-center gap-2 mb-8")
    set(:href_url, "/")
    set(:image_url, nil)
    set(:dark_image_url, nil)
    set(:text_class, "font-display text-3xl text-stone-900 dark:text-stone-100 tracking-tight")
    set(:text, "Juntos")
  end

  override Components.SignIn do
    set(:root_class, "glass-card w-full max-w-sm p-8 space-y-4")
    set(:strategy_class, "w-full")

    set(
      :authentication_error_container_class,
      "text-center text-sm text-red-600 dark:text-red-400 mt-2"
    )

    set(:authentication_error_text_class, "")
    set(:strategy_display_order, :forms_first)
  end

  override Components.MagicLink do
    set(:root_class, "w-full")
    set(:label_class, "block text-sm font-medium text-stone-700 dark:text-stone-300 mb-1.5")
    set(:form_class, "space-y-4")

    set(
      :request_flash_text,
      "Check your email — we sent you a sign-in link."
    )

    set(:disable_button_text, "Sending link…")
  end

  override Components.MagicLink.Input do
    set(
      :input_class,
      "w-full px-3 py-2 text-sm border border-stone-300 dark:border-stone-700 rounded-lg bg-white dark:bg-stone-900 text-stone-900 dark:text-stone-100 placeholder-stone-400 dark:placeholder-stone-600 focus:outline-none focus:border-amber-400 focus:ring-2 focus:ring-amber-400/20 transition-colors"
    )

    set(
      :submit_class,
      "w-full px-4 py-2.5 text-sm font-medium text-white bg-amber-600 hover:bg-amber-500 rounded-lg shadow-sm transition-all hover:-translate-y-px mt-4"
    )

    set(:submit_label, "Send sign-in link")
    set(:input_debounce, 300)
  end
end
