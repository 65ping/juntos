defmodule JuntosWeb.DashboardLive do
  use JuntosWeb, :live_view
  use LiveSvelte.Components

  require Ash.Query

  alias Juntos.Core.Conference

  def mount(_params, _session, socket) do
    conferences =
      if connected?(socket) do
        socket.assigns.current_user.id
        |> load_conferences()
        |> serialize_conferences()
      else
        []
      end

    {:ok,
     socket
     |> assign(:page_title, "Dashboard")
     |> assign(:conferences, conferences)}
  end

  def handle_event("create_conference", %{"conference" => params}, socket) do
    current_user = socket.assigns.current_user

    case build_slug(params["name"]) do
      nil ->
        {:noreply, put_flash(socket, :error, "Could not create conference: name is required.")}

      slug ->
        params_with_organizer =
          params
          |> Map.put("organizer_id", current_user.id)
          |> Map.put("slug", slug)

        case Ash.create(Conference, params_with_organizer, action: :create) do
          {:ok, conference} ->
            {:noreply,
             socket
             |> assign(:conferences, reload_conferences(current_user.id))
             |> put_flash(:info, "#{conference.name} created!")}

          {:error, %Ash.Error.Invalid{} = error} ->
            {:noreply,
             put_flash(socket, :error, "Could not create conference: #{format_errors(error)}")}

          {:error, _} ->
            {:noreply,
             put_flash(socket, :error, "Could not create conference. Please try again.")}
        end
    end
  end

  def handle_event("delete_conference", %{"id" => id}, socket) do
    current_user = socket.assigns.current_user

    case find_owned_conference(current_user.id, id) do
      {:ok, nil} ->
        {:noreply, put_flash(socket, :error, "Conference not found.")}

      {:ok, conference} ->
        Ash.destroy!(conference)
        {:noreply, assign(socket, :conferences, reload_conferences(current_user.id))}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not delete conference. Please try again.")}
    end
  end

  defp find_owned_conference(organizer_id, conference_id) do
    Conference
    |> Ash.Query.for_read(:for_organizer, %{organizer_id: organizer_id})
    |> Ash.Query.filter(id == ^conference_id)
    |> Ash.read_one()
  end

  defp reload_conferences(organizer_id) do
    organizer_id
    |> load_conferences()
    |> serialize_conferences()
  end

  defp load_conferences(organizer_id) do
    Conference
    |> Ash.Query.for_read(:for_organizer, %{organizer_id: organizer_id})
    |> Ash.Query.sort(inserted_at: :desc)
    |> Ash.read!()
  end

  defp serialize_conferences(conferences) do
    Enum.map(conferences, &serialize_conference/1)
  end

  defp serialize_conference(c) do
    %{
      "id" => c.id,
      "name" => c.name,
      "slug" => to_string(c.slug),
      "status" => to_string(c.status),
      "location" => c.location,
      "organizer_id" => c.organizer_id
    }
  end

  defp format_errors(%Ash.Error.Invalid{errors: errors}) do
    Enum.map_join(errors, ", ", &Exception.message/1)
  end

  defp build_slug(nil), do: nil
  defp build_slug(""), do: nil

  defp build_slug(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/\s+/, "-")
    |> String.trim("-")
    |> case do
      "" -> nil
      slug -> slug
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen px-6 py-12">
      <div class="max-w-4xl mx-auto">
        <p class="text-stone-500 text-sm mb-8">{@current_user.email}</p>
        <.ConferenceDashboard conferences={@conferences} socket={@socket} />
      </div>
    </div>
    """
  end
end
