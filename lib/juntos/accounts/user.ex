defmodule Juntos.Accounts.User do
  use Ash.Resource,
    domain: Juntos.Accounts,
    data_layer: AshSqlite.DataLayer,
    extensions: [AshAuthentication]

  sqlite do
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
end
