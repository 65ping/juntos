defmodule JuntosWeb.ConferenceLive do
  use JuntosWeb, :live_view

  alias Juntos.Core.Conference
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
           |> assign(:ticket_tiers, serialize_tiers(conference.ticket_tiers))}

        {:error, _} ->
          {:ok, push_navigate(socket, to: ~p"/")}
      end
    else
      {:ok,
       socket
       |> assign(:page_title, "Loading...")
       |> assign(:conference, nil)
       |> assign(:ticket_tiers, [])}
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

    Conference
    |> Ash.Query.for_read(:by_slug, %{slug: slug})
    |> Ash.Query.load(ticket_tiers: tiers_query)
    |> Ash.read_one()
  end

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
        <section class="px-6 py-20 sm:py-32 text-center border-b border-stone-200 dark:border-stone-800">
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

        <%= if @ticket_tiers != [] do %>
          <.ConferenceTickets ticket_tiers={@ticket_tiers} v-socket={@socket} />
        <% end %>
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
    do: "bg-emerald-50 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-400"

  defp status_classes(:cfp_closed),
    do: "bg-sky-50 dark:bg-sky-900/30 text-sky-700 dark:text-sky-400"

  defp status_classes(:scheduled),
    do: "bg-amber-50 dark:bg-amber-900/30 text-amber-700 dark:text-amber-400"

  defp status_classes(:complete),
    do: "bg-stone-100 dark:bg-stone-800 text-stone-500 dark:text-stone-400"

  defp status_label(:draft), do: "Draft"
  defp status_label(:cfp_open), do: "CFP Open"
  defp status_label(:cfp_closed), do: "CFP Closed"
  defp status_label(:scheduled), do: "Coming Soon"
  defp status_label(:complete), do: "Complete"
end
