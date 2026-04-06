defmodule Juntos.Core.Session do
  use Ash.Resource,
    domain: Juntos.Core,
    data_layer: AshPostgres.DataLayer

  @moduledoc false

  postgres do
    table("conference_sessions")
    repo(Juntos.Repo)
  end

  attributes do
    uuid_primary_key(:id)
    attribute(:title, :string, allow_nil?: false, public?: true)
    attribute(:description, :string, public?: true)
    attribute(:speaker_name, :string, public?: true)
    attribute(:speaker_bio, :string, public?: true)
    attribute(:starts_at, :utc_datetime, public?: true)
    attribute(:ends_at, :utc_datetime, public?: true)
    attribute(:day_number, :integer, allow_nil?: false, default: 1, public?: true)
    attribute(:room, :string, public?: true)

    attribute(:session_type, :atom,
      constraints: [one_of: [:talk, :workshop, :keynote, :panel, :break]],
      default: :talk,
      allow_nil?: false,
      public?: true
    )

    attribute(:position, :integer, allow_nil?: false, default: 0)
    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
  end

  relationships do
    belongs_to(:conference, Juntos.Core.Conference, allow_nil?: false, public?: true)
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([
        :title,
        :description,
        :speaker_name,
        :speaker_bio,
        :starts_at,
        :ends_at,
        :day_number,
        :room,
        :session_type,
        :position,
        :conference_id
      ])
    end

    update :update do
      accept([
        :title,
        :description,
        :speaker_name,
        :speaker_bio,
        :starts_at,
        :ends_at,
        :day_number,
        :room,
        :session_type,
        :position
      ])
    end

    read :for_conference do
      argument(:conference_id, :uuid, allow_nil?: false)
      filter(expr(conference_id == ^arg(:conference_id)))
    end
  end
end
