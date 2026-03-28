defmodule JuntosWeb.AuthOverrides do
  use AshAuthentication.Phoenix.Overrides

  @moduledoc false
  alias AshAuthentication.Phoenix.{Components, MagicSignInLive, SignInLive}

  override SignInLive do
    set(:root_class, "min-h-screen flex flex-col items-center justify-center px-4 bg-stone-50")
  end

  override MagicSignInLive do
    set(:root_class, "min-h-screen flex flex-col items-center justify-center px-4 bg-stone-50")
  end

  override Components.Banner do
    set(:root_class, "w-full flex flex-col items-center gap-1 mb-6")
    set(:href_url, "/")
    set(:image_url, nil)
    set(:dark_image_url, nil)
    set(:text_class, "text-3xl text-stone-900 tracking-tight")
    set(:text, "Juntos")
  end

  override Components.SignIn do
    set(:root_class, "glass-card w-full max-w-sm p-8 space-y-2")
    set(:strategy_class, "w-full")
    set(:authentication_error_container_class, "text-center text-sm text-red-600 mt-2")
    set(:authentication_error_text_class, "")
    set(:strategy_display_order, :forms_first)
  end

  override Components.MagicLink do
    set(:root_class, "w-full")
    set(:label_class, "block text-sm font-medium text-stone-700 mb-1")
    set(:form_class, "space-y-4")

    set(
      :request_flash_text,
      "Check your email — we sent you a sign-in link."
    )

    set(:disable_button_text, "Sending link…")
  end

  override Components.MagicLink.Input do
    set(
      :submit_class,
      "w-full px-4 py-2.5 text-sm font-medium text-white bg-amber-600 hover:bg-amber-500 rounded-lg shadow-sm transition-all hover:-translate-y-px mt-4"
    )

    set(:submit_label, "Send sign-in link")
    set(:input_debounce, 300)
  end
end
