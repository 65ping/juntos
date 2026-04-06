defmodule Juntos.Core.Conference do
  use Ash.Resource,
    domain: Juntos.Core,
    data_layer: AshPostgres.DataLayer

  @moduledoc false
  postgres do
    table("conferences")
    repo(Juntos.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    attribute(:name, :string, allow_nil?: false, public?: true)
    attribute(:slug, :ci_string, allow_nil?: false, public?: true)
    attribute(:description, :string, public?: true)
    attribute(:location, :string, public?: true)

    attribute(:status, :atom,
      constraints: [one_of: [:draft, :cfp_open, :cfp_closed, :scheduled, :complete]],
      default: :draft,
      allow_nil?: false,
      public?: true
    )

    attribute(:starts_at, :utc_datetime, public?: true)
    attribute(:ends_at, :utc_datetime, public?: true)
    attribute(:cfp_opens_at, :utc_datetime, public?: true)
    attribute(:cfp_closes_at, :utc_datetime, public?: true)

    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
  end

  identities do
    identity(:unique_slug, [:slug])
  end

  relationships do
    belongs_to :organizer, Juntos.Accounts.User, allow_nil?: false, public?: true
    has_many :ticket_tiers, Juntos.Core.TicketTier, public?: true
    has_many :sessions, Juntos.Core.Session, public?: true
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([
        :name,
        :slug,
        :description,
        :location,
        :status,
        :starts_at,
        :ends_at,
        :cfp_opens_at,
        :cfp_closes_at,
        :organizer_id
      ])
    end

    update :update do
      accept([
        :name,
        :description,
        :location,
        :status,
        :starts_at,
        :ends_at,
        :cfp_opens_at,
        :cfp_closes_at
      ])
    end

    read :by_slug do
      argument(:slug, :ci_string, allow_nil?: false)
      get?(true)
      filter(expr(slug == ^arg(:slug)))
    end

    read :published do
      filter(expr(status != :draft))
    end

    read :for_organizer do
      argument(:organizer_id, :uuid, allow_nil?: false)
      filter(expr(organizer_id == ^arg(:organizer_id)))
    end
  end
end
