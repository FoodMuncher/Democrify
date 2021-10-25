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
    session_id = generate_id()
    Registry.create(session_id)
    session_id
  end

  def exists?(session_id) do
    Registry.lookup(session_id) != {:error, :notfound}
  end

  def list_session(session_id) do
    # TODO: Use actual session ID
    Registry.lookup!(session_id)
    |> Worker.fetch_all()
  end

  def inc_votes(%Song{} = song, session_id) do
    Registry.lookup!(session_id)
    |> Worker.increment(song)
    |> broadcast(session_id, :songs_changed)
  end

  def get_song!(song_id, session_id) do
    Registry.lookup!(session_id)
    |> Worker.fetch(song_id)
  end

  def create_song(attrs, session_id) do
    Registry.lookup!(session_id)
    |> Worker.add(%Song{song_name: attrs["song_name"]})
    |> broadcast(session_id, :songs_changed)
  end

  def update_song(%Song{} = song, session_id, attrs) do
    Registry.lookup!(session_id)
    |> Worker.update(%{song | song_name: attrs["song_name"], votes: 0})
    |> broadcast(session_id, :songs_changed)
  end

  def delete_song(%Song{} = song, session_id) do
    Registry.lookup!(session_id)
    |> Worker.delete(song)
    |> broadcast(session_id, :songs_changed)
  end

  def change_song(%Song{} = song, attrs \\ %{}) do
    Song.changeset(song, attrs)
  end

  def subscribe(session_id) do
    Phoenix.PubSub.subscribe(Democrify.PubSub, "session:#{session_id}")
  end

  # Internal Functions
  # ========================================

  defp broadcast(songs, session_id, event) do
    Phoenix.PubSub.broadcast(Democrify.PubSub, "session:#{session_id}", {event, songs})
    songs
  end

  defp generate_id do
    min = String.to_integer("100000", 36)
    max = String.to_integer("ZZZZZZ", 36)

    max
    |> Kernel.-(min)
    |> :rand.uniform()
    |> Kernel.+(min)
    |> Integer.to_string(36)
  end
end
