defmodule Democrify.Spotify.Player do
  use GenServer, restart: :temporary

  alias Democrify.Spotify

  require Logger

  def start_link(session_id) do
    GenServer.start_link(__MODULE__, session_id)
  end

  def init(session_id) do
    # TODO: better start up, race condition here on access token being added and the first status check
    Process.send_after(self(), :check_status, 1000)
    {:ok, %{session_worker: self(), session_id: session_id, access_token: nil}}
  end

  def handle_info(:check_status, state) do
    Process.send_after(self(), :check_status, 1000)

    # TODO: add access_token to the state if it exists
    access_token = Democrify.Session.Data.fetch!(state.session_id)

    status = Spotify.get_player_status(access_token)

    # Logger.debug("Status: #{inspect(status)}")

    Logger.debug("Remaining #{status.progress_ms}ms of #{status.item.duration_ms}ms")

    {:noreply, state}
  end
end
