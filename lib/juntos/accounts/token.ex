defmodule Juntos.Accounts.Token do
  use Ash.Resource,
    domain: Juntos.Accounts,
    data_layer: AshSqlite.DataLayer,
    extensions: [AshAuthentication.TokenResource]

  sqlite do
    table("tokens")
    repo(Juntos.Repo)
  end

  actions do
    defaults([:read, :destroy])
  end
end
