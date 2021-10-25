defmodule Democrify.SessionFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Democrify.Session` context.
  """

  @doc """
  Generate a song.
  """
  def song_fixture(attrs \\ %{}) do
    {:ok, song} =
      attrs
      |> Enum.into(%{
        song_name: "some song_name",
        username: "some username",
        votes: 42
      })
      |> Democrify.Session.create_song()

    song
  end
end
