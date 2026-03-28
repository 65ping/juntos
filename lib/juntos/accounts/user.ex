defmodule Juntos.Accounts.User do
  use Ash.Resource,
    domain: Juntos.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication]

  postgres do
    table("users")
    repo(Juntos.Repo)
  end

  attributes do
    uuid_primary_key(:id)
    attribute(:email, :ci_string, allow_nil?: false, public?: true)
    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
  end

  identities do
    identity(:unique_email, [:email])
  end

  actions do
    defaults([:read, :destroy])
  end

  authentication do
    strategies do
      magic_link do
        identity_field(:email)
        sender(Juntos.Accounts.User.Senders.SendMagicLink)
        require_interaction? :true
      end
    end

    tokens do
      enabled?(true)
      token_resource(Juntos.Accounts.Token)
      require_token_presence_for_authentication? true

      signing_secret(fn _, _ ->
        Application.fetch_env(:juntos, :token_signing_secret)
      end)
    end
  end
end
