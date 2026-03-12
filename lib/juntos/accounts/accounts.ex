defmodule Juntos.Accounts do
  use Ash.Domain

  resources do
    resource(Juntos.Accounts.User)
    resource(Juntos.Accounts.Token)
  end
end
