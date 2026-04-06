defmodule Juntos.Messaging.Message do
  use Ash.Resource,
    domain: Juntos.Messaging,
    data_layer: AshPostgres.DataLayer

  @moduledoc false

  postgres do
    table("messages")
    repo(Juntos.Repo)
  end

  attributes do
    uuid_primary_key(:id)
    attribute(:body, :string, allow_nil?: false, public?: true)
    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
  end

  relationships do
    belongs_to(:conversation, Juntos.Messaging.Conversation, allow_nil?: false, public?: true)
    belongs_to(:sender, Juntos.Accounts.User, allow_nil?: false, public?: true)
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([:body, :conversation_id, :sender_id])
    end

    read :for_conversation do
      argument(:conversation_id, :uuid, allow_nil?: false)
      filter(expr(conversation_id == ^arg(:conversation_id)))
    end
  end
end
