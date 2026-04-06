defmodule JuntosWeb.ConferenceLive do
  use JuntosWeb, :live_view

  alias Juntos.Core.Conference
  alias Juntos.Core.Session
  alias Juntos.Core.TicketTier

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    if connected?(socket) do
      case load_conference(slug) do
        {:ok, nil} ->
          {:ok, push_navigate(socket, to: ~p"/")}

        {:ok, conference} ->
          {:ok,
           socket
           |> assign(:page_title, conference.name)
           |> assign(:conference, conference)
           |> assign(:ticket_tiers, serialize_tiers(conference.ticket_tiers))
           |> assign(:sessions, serialize_sessions(conference.sessions))
           |> assign(:organizer, serialize_organizer(conference.organizer))
           |> assign(:conference_info, serialize_conference_info(conference))}

        {:error, _} ->
          {:ok, push_navigate(socket, to: ~p"/")}
      end
    else
      {:ok,
       socket
       |> assign(:page_title, "Loading...")
       |> assign(:conference, nil)
       |> assign(:ticket_tiers, [])
       |> assign(:sessions, [])
       |> assign(:organizer, nil)
       |> assign(:conference_info, nil)}
    end
  end

  @impl true
  def handle_event("get_ticket", %{"tier_id" => _tier_id}, socket) do
    {:noreply, put_flash(socket, :info, "Ticket purchase coming soon!")}
  end

  defp load_conference(slug) do
    tiers_query =
      TicketTier
      |> Ash.Query.for_read(:read)
      |> Ash.Query.sort(position: :asc)

    sessions_query =
      Session
      |> Ash.Query.for_read(:read)
      |> Ash.Query.sort(day_number: :asc, position: :asc)

    Conference
    |> Ash.Query.for_read(:by_slug, %{slug: slug})
    |> Ash.Query.load(ticket_tiers: tiers_query, sessions: sessions_query, organizer: [])
    |> Ash.read_one()
  end

  defp serialize_sessions(sessions) do
    Enum.map(sessions, fn s ->
      %{
        "id" => s.id,
        "title" => s.title,
        "description" => s.description,
        "speaker_name" => s.speaker_name,
        "speaker_bio" => s.speaker_bio,
        "starts_at" => format_time(s.starts_at),
        "ends_at" => format_time(s.ends_at),
        "day_number" => s.day_number,
        "room" => s.room,
        "session_type" => to_string(s.session_type),
        "position" => s.position
      }
    end)
  end

  defp serialize_conference_info(conference) do
    %{
      "starts_at" => format_date(conference.starts_at),
      "ends_at" => format_date(conference.ends_at),
      "cfp_opens_at" => format_date(conference.cfp_opens_at),
      "cfp_closes_at" => format_date(conference.cfp_closes_at),
      "location" => conference.location,
      "session_count" => length(conference.sessions)
    }
  end

  defp format_date(nil), do: nil
  defp format_date(dt), do: Calendar.strftime(dt, "%B %-d, %Y")

  defp serialize_organizer(nil), do: nil

  defp serialize_organizer(user) do
    name =
      case user do
        %{display_name: n} when is_binary(n) and n != "" -> n
        %{email: e} -> e |> to_string() |> String.split("@") |> List.first()
      end

    %{"id" => user.id, "name" => name, "bio" => user.bio, "avatar_url" => user.avatar_url}
  end

  defp format_time(nil), do: nil
  defp format_time(dt), do: Calendar.strftime(dt, "%H:%M")

  defp serialize_tiers(tiers) do
    Enum.map(tiers, &serialize_tier/1)
  end

  defp serialize_tier(t) do
    %{
      "id" => t.id,
      "name" => t.name,
      "description" => t.description,
      "price_cents" => t.price_cents,
      "quantity" => t.quantity,
      "sold_count" => t.sold_count
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%= if is_nil(@conference) do %>
      <div class="min-h-screen flex items-center justify-center">
        <p class="text-stone-500 dark:text-stone-400">Loading...</p>
      </div>
    <% else %>
      <div class="min-h-screen">
        <section class="px-6 py-20 sm:py-32 text-center border-b border-stone-200 dark:border-stone-700/60">
          <div class="max-w-3xl mx-auto space-y-4">
            <.status_badge status={@conference.status} />
            <h1
              style="font-family: var(--font-display);"
              class="text-5xl sm:text-6xl text-stone-900 dark:text-stone-100 tracking-tight leading-tight"
            >
              {@conference.name}
            </h1>
            <%= if @conference.location do %>
              <p class="text-stone-500 dark:text-stone-400 text-lg">{@conference.location}</p>
            <% end %>
            <%= if @conference.starts_at do %>
              <p class="text-stone-500 dark:text-stone-400">
                {Calendar.strftime(@conference.starts_at, "%B %-d, %Y")}
              </p>
            <% end %>
            <%= if @conference.description do %>
              <p class="text-stone-600 dark:text-stone-300 leading-relaxed max-w-xl mx-auto mt-6">
                {@conference.description}
              </p>
            <% end %>
          </div>
        </section>

        <.ConferenceSchedule
          v-socket={@socket}
          sessions={@sessions}
          ticket_tiers={@ticket_tiers}
          organizer={@organizer}
          conference_info={@conference_info}
        />
      </div>
    <% end %>
    """
  end

  attr :status, :atom, required: true

  defp status_badge(assigns) do
    ~H"""
    <span class={[
      "inline-block px-3 py-1 text-xs font-semibold uppercase tracking-widest rounded-full",
      status_classes(@status)
    ]}>
      {status_label(@status)}
    </span>
    """
  end

  defp status_classes(:draft),
    do: "bg-stone-100 dark:bg-stone-800 text-stone-500 dark:text-stone-400"

  defp status_classes(:cfp_open),
    do: "bg-brand-50 dark:bg-brand-950/60 text-brand-800 dark:text-brand-400"

  defp status_classes(:cfp_closed),
    do: "bg-stone-100 dark:bg-stone-800/60 text-stone-600 dark:text-stone-400"

  defp status_classes(:scheduled),
    do: "bg-action-50 dark:bg-action-500/10 text-action-600 dark:text-action-400"

  defp status_classes(:complete),
    do: "bg-stone-100 dark:bg-stone-800 text-stone-500 dark:text-stone-400"

  defp status_label(:draft), do: "Draft"
  defp status_label(:cfp_open), do: "CFP Open"
  defp status_label(:cfp_closed), do: "CFP Closed"
  defp status_label(:scheduled), do: "Coming Soon"
  defp status_label(:complete), do: "Complete"
end
