defmodule DemocrifyWeb.SongLive.SongComponent do
  use DemocrifyWeb, :live_component

  require Logger

  def render(assigns) do
    Logger.debug("Route: #{Routes.song_index_path(assigns.socket, :edit, assigns.song.id)}")

    ~L"""
    <div id="song-<%= @song.id %>" class="song">
      <div class="row">
        <div class="column column-10">
          <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/1/19/Spotify_logo_without_text.svg/1024px-Spotify_logo_without_text.svg.png" alt="alternatetext">
        </div>
        <div class="column column-90 song-name">
          <b><%= @song.username %></b>
          <br/>
          <%= @song.song_name %>
        </div>
      </div>

      <div class="row">
        <div class="column">
        <a href="#" phx-click="vote" phx-target="<%= @myself %>">
          <p>Votes: <%= @song.votes %></p>
        </a>
        </div>
        <div class="row">
          <%= live_patch to: Routes.song_index_path(@socket, :edit, @song.id) do %>
            <p>edit</p>
          <% end %>
          &nbsp
          <%= link to: "#", phx_click: "delete", phx_value_id: @song.id do %>
            <p>delete</p>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("vote", _, socket) do
    Democrify.Session.inc_votes(socket.assigns.song)
    {:noreply, socket}
  end
end
