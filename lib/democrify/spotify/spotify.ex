defmodule Democrify.Spotify do
  @moduledoc """
  Module for handling any Spotify API interactions
  """

  alias Democrify.Spotify.{Tokens, Track, Search}

  require Logger

  @redirect_uri "http://localhost:4000/callback"
  @scope "user-read-private user-read-email user-read-playback-state user-modify-playback-state"
  @client_id "4ccc8676aaf54c94a6400ce027c1c93e"
  @client_secret "7a60fbf860574f59a73702e27e7265ff"

  # ===========================================================
  #  API Functions
  # ===========================================================

  def authorize_url do
    "https://accounts.spotify.com/authorize/?response_type=code&client_id=#{@client_id}&scope=#{@scope}&redirect_uri=#{@redirect_uri}"
  end

  def get_authorisation_tokens(code) do
    url = "https://accounts.spotify.com/api/token"

    request_body =
      {:form,
       [
         grant_type: "authorization_code",
         code: code,
         redirect_uri: @redirect_uri,
         client_id: @client_id,
         client_secret: @client_secret
       ]}

    response = HTTPoison.post!(url, request_body)
    Tokens.constructor(response)
  end

  def get_track(track_id, access_token) do
    response =
      HTTPoison.get!("https://api.spotify.com/v1/tracks/#{track_id}",
        Authorization: "Bearer #{access_token}"
      )

    Track.constructor(response)
  end

  def search_tracks(query, access_token) do
    response =
      HTTPoison.get!(
        URI.encode("https://api.spotify.com/v1/search?q=#{query}&type=track&limit=10"),
        Authorization: "Bearer #{access_token}"
      )

    Search.constructor(response)
  end
end
