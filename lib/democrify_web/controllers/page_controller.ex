defmodule DemocrifyWeb.PageController do
  use DemocrifyWeb, :controller

  alias Democrify.Session
  alias Democrify.Session.Data, as: SessionData

  @redirect_uri "http://localhost:4000/callback"
  @client_id "4ccc8676aaf54c94a6400ce027c1c93e"
  @client_secret "7a60fbf860574f59a73702e27e7265ff"

  # ===========================================================
  # Home Page Handlers
  # ===========================================================

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def join(conn, params) do
    # TODO: Check session exists, if it doesn't send to home with a flash card

    session_id = params["session_id"]

    access_token = SessionData.fetch!(session_id)

    conn
    |> put_session(:session_id, session_id)
    |> put_session(:access_token, access_token)
    |> redirect(to: Routes.song_index_path(conn, :index))
  end

  # ===========================================================
  #  Spotify Login Handlers
  # ===========================================================

  def login(conn, _params) do
    scope =
      "user-read-private user-read-email user-read-playback-state user-modify-playback-state"

    url =
      "https://accounts.spotify.com/authorize/?response_type=code&client_id=" <>
        @client_id <> "&scope=" <> scope <> "&redirect_uri=" <> @redirect_uri

    redirect(conn, external: url)
  end

  def callback(conn, params) do
    url = "https://accounts.spotify.com/api/token"

    request_body =
      {:form,
       [
         grant_type: "authorization_code",
         code: params["code"],
         redirect_uri: @redirect_uri,
         client_id: @client_id,
         client_secret: @client_secret
       ]}

    response = HTTPoison.post!(url, request_body)
    response_body = JSON.decode!(response.body)

    session_id = get_session(conn, "session_id")
    # TODO: kill existing session, or ask to resume
    session_id =
      if session_id == nil || not Session.exists?(session_id) do
        Session.create_session()
      else
        session_id
      end

    access_token = response_body["access_token"]

    SessionData.add(session_id, access_token)

    conn
    |> put_session(:session_id, session_id)
    |> put_session(:access_token, access_token)
    |> redirect(to: Routes.song_index_path(conn, :index))
  end
end
