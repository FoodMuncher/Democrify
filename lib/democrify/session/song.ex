defmodule Democrify.Session.Song do
  use Ecto.Schema
  import Ecto.Changeset

  schema "session" do
    field(:song_name, :string)
    field(:username, :string, default: "Joe")
    field(:votes, :integer, default: 0)

    timestamps()
  end

  @doc false
  def changeset(song, attrs) do
    song
    |> cast(attrs, [:song_name])
    |> validate_required([:song_name])
  end
end
