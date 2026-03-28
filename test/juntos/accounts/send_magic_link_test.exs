defmodule Juntos.Accounts.User.Senders.SendMagicLinkTest do
  use JuntosWeb.ConnCase, async: false

  alias Juntos.Accounts.User.Senders.SendMagicLink

  describe "send/3" do
    test "delivers email to user's email address", %{} do
      user = create_user()
      {:ok, token, _claims} = AshAuthentication.Jwt.token_for_user(user)

      SendMagicLink.send(user, token, [])

      assert_received {:email, email}
      assert email.subject == "Your sign-in link for Juntos"
      assert Enum.any?(email.to, fn {_name, addr} -> addr == to_string(user.email) end)
      assert email.text_body =~ "magic_link"
    end

    test "delivers email when given a raw email string", %{} do
      user = create_user()
      {:ok, token, _claims} = AshAuthentication.Jwt.token_for_user(user)
      email_address = "raw@example.com"

      SendMagicLink.send(email_address, token, [])

      assert_received {:email, email}
      assert Enum.any?(email.to, fn {_name, addr} -> addr == email_address end)
    end
  end
end
