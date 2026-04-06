defmodule Juntos.Messaging.Conversation do
  use Ash.Resource,
    domain: Juntos.Messaging,
    data_layer: AshPostgres.DataLayer

  @moduledoc false

  postgres do
    table("conversations")
    repo(Juntos.Repo)
  end

  attributes do
    uuid_primary_key(:id)
    attribute(:subject, :string, public?: true)
    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
  end

  relationships do
    has_many(:participants, Juntos.Messaging.ConversationParticipant, public?: true)
    has_many(:messages, Juntos.Messaging.Message, public?: true)
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([:subject])
    end

    read :for_user do
      argument(:user_id, :uuid, allow_nil?: false)

      filter(expr(exists(participants, user_id == ^arg(:user_id))))
    end
  end
end
