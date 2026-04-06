defmodule Juntos.Core do
  use Ash.Domain

  @moduledoc false
  resources do
    resource(Juntos.Core.Conference)
    resource(Juntos.Core.TicketTier)
    resource(Juntos.Core.Session)
  end
end
