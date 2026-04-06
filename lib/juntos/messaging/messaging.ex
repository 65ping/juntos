defmodule Juntos.Messaging do
  use Ash.Domain

  @moduledoc false
  resources do
    resource(Juntos.Messaging.Conversation)
    resource(Juntos.Messaging.ConversationParticipant)
    resource(Juntos.Messaging.Message)
  end
end
