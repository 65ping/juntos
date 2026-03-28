defmodule Juntos.Accounts do
  use Ash.Domain

  @moduledoc false
  resources do
    resource(Juntos.Accounts.User)
    resource(Juntos.Accounts.Token)
  end
end
