defmodule Juntos.Accounts.Token do
  use Ash.Resource,
    domain: Juntos.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource]

  postgres do
    table("tokens")
    repo(Juntos.Repo)
  end

  actions do
    defaults([:read, :destroy])
  end
end
