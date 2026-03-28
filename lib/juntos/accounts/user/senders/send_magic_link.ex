defmodule Juntos.Accounts.User.Senders.SendMagicLink do
  @moduledoc false
  use AshAuthentication.Sender
  use JuntosWeb, :verified_routes

  @impl AshAuthentication.Sender
  def send(user_or_email, token, _opts) do
    email =
      case user_or_email do
        %{email: email} -> to_string(email)
        email -> to_string(email)
      end

    magic_link_url = url(~p"/auth/user/magic_link/?token=#{token}")

    Juntos.Mailer.deliver(
      Swoosh.Email.new()
      |> Swoosh.Email.to(email)
      |> Swoosh.Email.from({"Juntos", "noreply@juntos.app"})
      |> Swoosh.Email.subject("Your sign-in link for Juntos")
      |> Swoosh.Email.text_body("""
      Hi,

      Click the link below to sign in to Juntos. This link expires in 10 minutes.

      #{magic_link_url}

      If you didn't request this, you can safely ignore this email.
      """)
    )
  end
end
