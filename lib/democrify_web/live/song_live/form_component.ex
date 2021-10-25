defmodule DemocrifyWeb.SongLive.FormComponent do
  use DemocrifyWeb, :live_component

  alias Democrify.Session

  require Logger

  @impl true
  def mount(socket) do
    IO.inspect("mount socket: #{inspect(socket)}")
    {:ok, socket}
  end

  @impl true
  def update(%{song: song} = assigns, socket) do
    IO.inspect("assigns: #{inspect(assigns)}")
    IO.inspect("socket: #{inspect(socket)}")
    changeset = Session.change_song(song)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"song" => song_params}, socket) do
    changeset =
      socket.assigns.song
      |> Session.change_song(song_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"song" => song_params} = map, socket) do
    Logger.debug("map: #{inspect(map)} socket: #{inspect(socket.assigns)}")
    save_song(socket, socket.assigns.action, song_params)
  end

  defp save_song(socket, :edit, song_params) do
    Logger.debug("SAVE EDIT session_id: #{socket.assigns["session_id"]}")
    Session.update_song(socket.assigns.song, socket.assigns["session_id"], song_params)

    {:noreply,
     socket
     |> put_flash(:info, "Song updated successfully")
     |> push_redirect(to: socket.assigns.return_to)}
  end

  defp save_song(socket, :new, song_params) do
    Logger.debug("SAVE NEW session_id: #{socket.assigns["session_id"]}")
    Session.create_song(song_params, socket.assigns["session_id"])

    {:noreply,
     socket
     |> put_flash(:info, "Song created successfully")
     |> push_redirect(to: socket.assigns.return_to)}
  end
end
