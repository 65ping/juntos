defmodule JuntosWeb.ConversationLive do
  use JuntosWeb, :live_view

  alias Juntos.Messaging.Conversation
  alias Juntos.Messaging.Message

  @impl true
  def mount(%{"conversation_id" => conversation_id}, _session, socket) do
    current_user = socket.assigns.current_user

    unless current_user do
      {:ok, redirect(socket, to: "/")}
    else
      if connected?(socket) do
        case load_conversation(conversation_id, current_user) do
          nil ->
            {:ok, redirect(socket, to: "/")}

          conversation ->
            Phoenix.PubSub.subscribe(Juntos.PubSub, "conversation:#{conversation_id}")
            messages = load_messages(conversation_id, current_user)

            {:ok,
             socket
             |> assign(:page_title, "Messages")
             |> assign(:conversation, serialize_conversation(conversation))
             |> assign(:messages, messages)
             |> assign(:conversation_id, conversation_id)}
        end
      else
        {:ok,
         socket
         |> assign(:page_title, "Messages")
         |> assign(:conversation, %{"id" => conversation_id, "subject" => nil})
         |> assign(:messages, [])
         |> assign(:conversation_id, conversation_id)}
      end
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.MessageThread
      v-socket={@socket}
      conversation={@conversation}
      messages={@messages}
      current_user_id={@current_user.id}
    />
    """
  end

  @impl true
  def handle_event("send_message", %{"body" => body}, socket) when body != "" do
    current_user = socket.assigns.current_user
    conversation_id = socket.assigns.conversation_id

    case Ash.create(
           Message,
           %{body: body, conversation_id: conversation_id, sender_id: current_user.id},
           actor: current_user
         ) do
      {:ok, message} ->
        serialized = serialize_message(message, current_user)

        Phoenix.PubSub.broadcast(
          Juntos.PubSub,
          "conversation:#{conversation_id}",
          {:new_message, serialized}
        )

        {:noreply, update(socket, :messages, fn msgs -> msgs ++ [serialized] end)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  def handle_event("send_message", _params, socket), do: {:noreply, socket}

  @impl true
  def handle_info({:new_message, message}, socket) do
    if message["sender_id"] != socket.assigns.current_user.id do
      {:noreply, update(socket, :messages, fn msgs -> msgs ++ [message] end)}
    else
      {:noreply, socket}
    end
  end

  defp load_conversation(conversation_id, current_user) do
    Conversation
    |> Ash.Query.for_read(:for_user, %{user_id: current_user.id}, actor: current_user)
    |> Ash.read!()
    |> Enum.find(&(&1.id == conversation_id))
  end

  defp load_messages(conversation_id, current_user) do
    Message
    |> Ash.Query.for_read(:for_conversation, %{conversation_id: conversation_id},
      actor: current_user
    )
    |> Ash.Query.load(:sender)
    |> Ash.Query.sort(inserted_at: :asc)
    |> Ash.read!()
    |> Enum.map(&serialize_message(&1, current_user))
  end

  defp load_sender_name(sender) do
    case sender do
      %{display_name: name} when is_binary(name) and name != "" ->
        name

      %{email: email} ->
        email |> to_string() |> String.split("@") |> List.first()
    end
  end

  defp serialize_message(message, current_user) do
    sender_name =
      case message do
        %{sender: %Ash.NotLoaded{}} -> "Unknown"
        %{sender: sender} -> load_sender_name(sender)
      end

    %{
      "id" => message.id,
      "body" => message.body,
      "sender_id" => message.sender_id,
      "sender_name" => sender_name,
      "inserted_at" => Calendar.strftime(message.inserted_at, "%H:%M"),
      "is_own" => message.sender_id == current_user.id
    }
  end

  defp serialize_conversation(conversation) do
    %{"id" => conversation.id, "subject" => conversation.subject}
  end
end
