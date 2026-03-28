defmodule Juntos.Core.TicketTier do
  use Ash.Resource,
    domain: Juntos.Core,
    data_layer: AshPostgres.DataLayer

  @moduledoc false
  postgres do
    table("ticket_tiers")
    repo(Juntos.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    attribute(:name, :string, allow_nil?: false, public?: true)
    attribute(:description, :string, public?: true)
    attribute(:price_cents, :integer, allow_nil?: false, default: 0, public?: true)
    attribute(:quantity, :integer, public?: true)
    attribute(:sold_count, :integer, allow_nil?: false, default: 0, public?: true)
    attribute(:position, :integer, allow_nil?: false, default: 0)

    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
  end

  relationships do
    belongs_to :conference, Juntos.Core.Conference, allow_nil?: false, public?: true
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([:name, :description, :price_cents, :quantity, :position, :conference_id])
    end

    update :update do
      accept([:name, :description, :price_cents, :quantity, :position])
    end
  end
end
