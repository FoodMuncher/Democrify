defmodule Democrify.Session do
  @moduledoc """
  The Session context.
  """

  require Logger

  alias Democrify.Session.Song
  alias Democrify.SessionRegistry, as: Registry
  alias Democrify.SessionWorker, as: Worker

  # External Functions
  # ========================================

  def create_session do
    # session_id = generate_id()
    Registry.create()
    # session_id

    # Hard coded for now
    12
  end

  def exists?() do
    Registry.lookup() != {:error, :notfound}
  end

  def list_session() do
    # TODO: Use actual session ID
    Registry.lookup!()
    |> Worker.fetch_all()
  end

  def inc_votes(%Song{} = song) do
    Registry.lookup!()
    |> Worker.increment(song)
    |> broadcast(:songs_changed)
  end

  def get_song!(song_id) do
    Registry.lookup!()
    |> Worker.fetch(song_id)
  end

  def create_song(attrs) do
    Registry.lookup!()
    |> Worker.add(%Song{song_name: attrs["song_name"]})
    |> broadcast(:songs_changed)
  end

  def update_song(%Song{} = song, attrs) do
    Registry.lookup!()
    |> Worker.update(%{song | song_name: attrs["song_name"], votes: 0})
    |> broadcast(:songs_changed)
  end

  def delete_song(%Song{} = song) do
    Registry.lookup!()
    |> Worker.delete(song)
    |> broadcast(:songs_changed)
  end

  def change_song(%Song{} = song, attrs \\ %{}) do
    Song.changeset(song, attrs)
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(Democrify.PubSub, "session")
  end

  # Internal Functions
  # ========================================

  defp broadcast(songs, event) do
    Phoenix.PubSub.broadcast(Democrify.PubSub, "session", {event, songs})
    songs
  end
end
