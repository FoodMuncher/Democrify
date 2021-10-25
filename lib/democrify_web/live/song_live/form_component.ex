defmodule DemocrifyWeb.SongLive.FormComponent do
  use DemocrifyWeb, :live_component

  alias Democrify.Session

  require Logger

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :suggested_songs, nil)}
  end

  @impl true
  def update(%{song: song} = assigns, socket) do
    changeset = Session.change_song(song)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"song" => song_params}, socket) do
    Logger.debug("Here Validate: #{inspect(song_params)}")

    text = song_params["text"]

    suggested_songs =
      if text && text != "" do
        ["song_1", "song_2"]
      else
        nil
      end

    changeset =
      socket.assigns.song
      |> Session.change_song(song_params)
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign(:changeset, changeset)
      |> assign(:suggested_songs, suggested_songs)

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
