defmodule JuntosWeb.ConferenceLive do
  use JuntosWeb, :live_view
  use LiveSvelte.Components

  alias Juntos.Core.Conference
  alias Juntos.Core.TicketTier

  def mount(%{"slug" => slug}, _session, socket) do
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
  end

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

  def render(assigns) do
    ~H"""
    <div class="min-h-screen">
      <section class="px-6 py-20 sm:py-32 text-center border-b border-stone-200">
        <div class="max-w-3xl mx-auto space-y-4">
          <.status_badge status={@conference.status} />
          <h1
            style="font-family: var(--font-display);"
            class="text-5xl sm:text-6xl text-stone-900 tracking-tight leading-tight"
          >
            {@conference.name}
          </h1>
          <%= if @conference.location do %>
            <p class="text-stone-500 text-lg">{@conference.location}</p>
          <% end %>
          <%= if @conference.starts_at do %>
            <p class="text-stone-500">
              {Calendar.strftime(@conference.starts_at, "%B %-d, %Y")}
            </p>
          <% end %>
          <%= if @conference.description do %>
            <p class="text-stone-600 leading-relaxed max-w-xl mx-auto mt-6">
              {@conference.description}
            </p>
          <% end %>
        </div>
      </section>

      <%= if @ticket_tiers != [] do %>
        <.ConferenceTickets ticket_tiers={@ticket_tiers} socket={@socket} />
      <% end %>
    </div>
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

  defp status_classes(:draft), do: "bg-stone-100 text-stone-500"
  defp status_classes(:cfp_open), do: "bg-emerald-50 text-emerald-700"
  defp status_classes(:cfp_closed), do: "bg-sky-50 text-sky-700"
  defp status_classes(:scheduled), do: "bg-amber-50 text-amber-700"
  defp status_classes(:complete), do: "bg-stone-100 text-stone-500"

  defp status_label(:draft), do: "Draft"
  defp status_label(:cfp_open), do: "CFP Open"
  defp status_label(:cfp_closed), do: "CFP Closed"
  defp status_label(:scheduled), do: "Coming Soon"
  defp status_label(:complete), do: "Complete"
end
