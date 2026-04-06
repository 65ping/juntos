defmodule JuntosWeb.ProfileLive do
  use JuntosWeb, :live_view

  alias Juntos.Accounts.User
  alias Juntos.Core.Conference
  alias Juntos.Messaging.Conversation
  alias Juntos.Messaging.ConversationParticipant

  @allowed_tabs ~w(about conferences tickets inbox)

  @impl true
  def mount(%{"user_id" => user_id}, _session, socket) do
    current_user = socket.assigns.current_user

    if connected?(socket) do
      case Ash.get(User, user_id) do
        {:ok, profile_user} ->
          {:ok, init_socket(socket, current_user, profile_user)}

        {:error, _} ->
          {:ok, redirect(socket, to: "/")}
      end
    else
      {:ok, placeholder_socket(socket)}
    end
  end

  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    if connected?(socket) do
      if current_user do
        {:ok, init_socket(socket, current_user, current_user)}
      else
        {:ok, redirect(socket, to: "/")}
      end
    else
      {:ok, placeholder_socket(socket)}
    end
  end

  defp placeholder_socket(socket) do
    socket
    |> assign(:page_title, "Loading...")
    |> assign(:profile_user, nil)
    |> assign(:is_own_profile, false)
    |> assign(:active_tab, :about)
    |> assign(:editing, false)
    |> assign(:tab_data, %{})
    |> assign(:profile_user_id, nil)
  end

  defp init_socket(socket, current_user, profile_user) do
    is_own = current_user && current_user.id == profile_user.id

    socket
    |> assign(:page_title, profile_user.display_name || "Profile")
    |> assign(:profile_user, serialize_user(profile_user))
    |> assign(:is_own_profile, is_own)
    |> assign(:active_tab, :about)
    |> assign(:editing, false)
    |> assign(:tab_data, %{})
    |> assign(:profile_user_id, profile_user.id)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%= if is_nil(@profile_user) do %>
      <div class="min-h-screen flex items-center justify-center">
        <p class="text-stone-500 dark:text-stone-400">Loading...</p>
      </div>
    <% else %>
      <.UserProfile
        v-socket={@socket}
        profile_user={@profile_user}
        is_own_profile={@is_own_profile}
        active_tab={to_string(@active_tab)}
        editing={@editing}
        tab_data={@tab_data}
      />
    <% end %>
    """
  end

  @impl true
  def handle_event("switch_tab", %{"tab" => tab}, socket) when tab in @allowed_tabs do
    active_tab = String.to_existing_atom(tab)
    socket = assign(socket, :active_tab, active_tab)
    {:noreply, load_tab_data(socket, active_tab)}
  end

  def handle_event("switch_tab", _params, socket), do: {:noreply, socket}

  def handle_event("edit_profile", _params, %{assigns: %{is_own_profile: true}} = socket) do
    {:noreply, assign(socket, :editing, true)}
  end

  def handle_event("edit_profile", _params, socket), do: {:noreply, socket}

  def handle_event("cancel_edit", _params, socket) do
    {:noreply, assign(socket, :editing, false)}
  end

  def handle_event("save_profile", params, %{assigns: %{is_own_profile: true}} = socket) do
    user = Ash.get!(User, socket.assigns.profile_user_id)

    attrs = Map.take(params, ["display_name", "bio", "avatar_url"])

    case Ash.update(user, attrs, action: :update_profile, actor: socket.assigns.current_user) do
      {:ok, updated_user} ->
        {:noreply,
         socket
         |> assign(:profile_user, serialize_user(updated_user))
         |> assign(:editing, false)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  def handle_event("save_profile", _params, socket), do: {:noreply, socket}

  def handle_event("send_message_to_user", _params, socket) do
    current_user = socket.assigns.current_user

    if is_nil(current_user) do
      {:noreply, socket}
    else
      do_send_message_to_user(socket, current_user)
    end
  end

  defp do_send_message_to_user(socket, current_user) do
    other_user_id = socket.assigns.profile_user_id

    case create_or_find_conversation(current_user, other_user_id) do
      {:ok, conversation} ->
        {:noreply, push_navigate(socket, to: ~p"/messages/#{conversation.id}")}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp create_or_find_conversation(current_user, other_user_id) do
    existing =
      Conversation
      |> Ash.Query.for_read(:for_user, %{user_id: current_user.id}, actor: current_user)
      |> Ash.Query.load(:participants)
      |> Ash.read!()
      |> Enum.find(fn conv ->
        participant_ids = Enum.map(conv.participants, & &1.user_id)

        other_user_id in participant_ids && current_user.id in participant_ids &&
          length(participant_ids) == 2
      end)

    if existing do
      {:ok, existing}
    else
      Juntos.Repo.transaction(fn ->
        {:ok, conv} = Ash.create(Conversation, %{subject: nil}, actor: current_user)

        Ash.create!(
          ConversationParticipant,
          %{conversation_id: conv.id, user_id: current_user.id},
          actor: current_user
        )

        Ash.create!(ConversationParticipant, %{conversation_id: conv.id, user_id: other_user_id},
          actor: current_user
        )

        conv
      end)
    end
  end

  defp load_tab_data(socket, :conferences) do
    user_id = socket.assigns.profile_user_id

    conferences =
      Conference
      |> Ash.Query.for_read(:for_organizer, %{organizer_id: user_id})
      |> Ash.read!()
      |> Enum.map(fn c ->
        %{"id" => c.id, "name" => c.name, "slug" => c.slug, "status" => to_string(c.status)}
      end)

    tab_data = Map.put(socket.assigns.tab_data, "conferences", conferences)
    assign(socket, :tab_data, tab_data)
  end

  defp load_tab_data(socket, :inbox) do
    if socket.assigns.is_own_profile do
      current_user = socket.assigns.current_user

      conversations =
        Conversation
        |> Ash.Query.for_read(:for_user, %{user_id: current_user.id}, actor: current_user)
        |> Ash.Query.load([:participants, :messages])
        |> Ash.read!()
        |> Enum.map(fn conv ->
          other =
            Enum.find(conv.participants, fn p -> p.user_id != current_user.id end)

          last_msg = List.last(conv.messages)

          %{
            "id" => conv.id,
            "other_user_id" => other && other.user_id,
            "last_message" => last_msg && last_msg.body,
            "updated_at" => last_msg && format_time(last_msg.inserted_at)
          }
        end)

      tab_data = Map.put(socket.assigns.tab_data, "conversations", conversations)
      assign(socket, :tab_data, tab_data)
    else
      socket
    end
  end

  defp load_tab_data(socket, _tab), do: socket

  defp serialize_user(user) do
    %{
      "id" => user.id,
      "email" => to_string(user.email),
      "display_name" => user.display_name,
      "bio" => user.bio,
      "avatar_url" => user.avatar_url
    }
  end

  defp format_time(nil), do: nil

  defp format_time(dt) do
    Calendar.strftime(dt, "%b %-d")
  end
end
