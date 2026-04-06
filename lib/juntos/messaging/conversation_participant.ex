defmodule Juntos.Messaging.ConversationParticipant do
  use Ash.Resource,
    domain: Juntos.Messaging,
    data_layer: AshPostgres.DataLayer

  @moduledoc false

  postgres do
    table("conversation_participants")
    repo(Juntos.Repo)
  end

  attributes do
    uuid_primary_key(:id)
    attribute(:last_read_at, :utc_datetime, public?: true)
    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
  end

  identities do
    identity(:unique_participant, [:conversation_id, :user_id])
  end

  relationships do
    belongs_to(:conversation, Juntos.Messaging.Conversation, allow_nil?: false, public?: true)
    belongs_to(:user, Juntos.Accounts.User, allow_nil?: false, public?: true)
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([:conversation_id, :user_id])
    end

    update :mark_read do
      change(set_attribute(:last_read_at, &DateTime.utc_now/0))
    end
  end
end
