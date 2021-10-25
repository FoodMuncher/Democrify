defmodule DemocrifyWeb.SongLive.Index do
  use DemocrifyWeb, :live_view

  alias Democrify.Session
  alias Democrify.Session.Song

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    Logger.debug("Here!!!!!!!!!!!!!!!")

    if connected?(socket), do: Session.subscribe()

    {:ok,
     socket
     |> assign(:session, Session.list_session())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => song_id}) do
    socket
    |> assign(:page_title, "Edit Song")
    |> assign(:song, Session.get_song!(song_id))
  end

  defp apply_action(socket, :new, _params) do
    IO.inspect("here son: #{inspect(socket)}")

    socket
    |> assign(:page_title, "New Song")
    |> assign(:song, %Song{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Session")
    |> assign(:song, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    ## TODO: Potnetial improvement, delete handles ID and song, saves fetching and deleting...
    songs =
      Session.get_song!(id)
      |> Session.delete_song()

    {:noreply, assign(socket, :session, songs)}
  end

  @impl true
  def handle_info({:songs_changed, songs}, socket) do
    {:noreply, assign(socket, :session, songs)}
  end
end
