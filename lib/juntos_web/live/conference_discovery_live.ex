defmodule JuntosWeb.ConferenceDiscoveryLive do
  use JuntosWeb, :live_view

  alias Juntos.Core.Conference

  @impl true
  def mount(_params, _session, socket) do
    conferences =
      if connected?(socket) do
        Conference
        |> Ash.Query.for_read(:published)
        |> Ash.Query.load([:ticket_tiers, :organizer])
        |> Ash.read!()
        |> Enum.map(&serialize_conference/1)
      else
        []
      end

    {:ok,
     socket
     |> assign(:page_title, "Browse Conferences")
     |> assign(:conferences, conferences)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.ConferenceDiscoveryList v-socket={@socket} conferences={@conferences} />
    """
  end

  defp serialize_conference(conference) do
    organizer_name =
      case conference.organizer do
        %{display_name: name} when is_binary(name) and name != "" ->
          name

        %{email: email} ->
          email
          |> to_string()
          |> String.split("@")
          |> List.first()
      end

    {min_price, max_price} =
      case conference.ticket_tiers do
        [] ->
          {0, 0}

        tiers ->
          prices = Enum.map(tiers, & &1.price_cents)
          {Enum.min(prices), Enum.max(prices)}
      end

    %{
      "id" => to_string(conference.id),
      "name" => conference.name,
      "slug" => to_string(conference.slug),
      "status" => to_string(conference.status),
      "location" => conference.location,
      "starts_at" => format_datetime(conference.starts_at),
      "ends_at" => format_datetime(conference.ends_at),
      "organizer_name" => organizer_name,
      "min_price_cents" => min_price,
      "max_price_cents" => max_price
    }
  end

  defp format_datetime(nil), do: nil

  defp format_datetime(dt) do
    Calendar.strftime(dt, "%b %-d, %Y")
  end
end
