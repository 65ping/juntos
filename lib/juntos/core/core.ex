defmodule Juntos.Core do
  use Ash.Domain

  resources do
    resource(Juntos.Core.Conference)
    resource(Juntos.Core.TicketTier)
  end
end
