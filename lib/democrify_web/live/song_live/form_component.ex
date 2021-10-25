defmodule DemocrifyWeb.SongLive.FormComponent do
  use DemocrifyWeb, :live_component

  alias Democrify.Session

  require Logger

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(%{song: song} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, Session.change_song(song))}
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
    save_song(socket, socket.assigns.action, song_params)
  end

  defp save_song(socket, :edit, song_params) do
    Session.update_song(socket.assigns.song, socket.assigns.session_id, song_params)

    {:noreply,
     socket
     |> put_flash(:info, "Song updated successfully")
     |> push_redirect(to: socket.assigns.return_to)}
  end

  defp save_song(socket, :new, song_params) do
    Session.create_song(song_params, socket.assigns.session_id)

    {:noreply,
     socket
     |> put_flash(:info, "Song created successfully")
     |> push_redirect(to: socket.assigns.return_to)}
  end
end
