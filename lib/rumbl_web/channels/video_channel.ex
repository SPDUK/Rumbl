defmodule RumblWeb.VideoChannel do
  @moduledoc """
  Allows connections through join and also let users disconnect and send events.

  Sockets will hold all of the state for a given conversation.
  Each socket can hold its own state in the socket.assigns ield, which typically holds a map.
  """
  use RumblWeb, :channel

  @doc """
  add the video ID from our topic to socket.assigns.
  """
  def join("videos:" <> video_id, _params, socket) do
    {:ok, socket}
  end

  @doc """
  This function will handle all incoming messages to a channel, pushed
  directly from the remote client.
  """
  def handle_in("new_annotation", params, socket) do
    broadcast!(socket, "new_annotation", %{
      user: %{username: "anon"},
      body: params["body"],
      at: params["at"]
    })

    {:reply, :ok, socket}
  end
end

# The handle_info callback is invoked whenever an Elixir message reaches the
# channel. In this case, we match on the periodic :ping message and increase a
# counter every time it arrives.

# Our handle_info takes our socket, takes the existing count (or a default of
# 1), and increases that count by one. We then return a tagged tuple. :noreply
# means we’re not sending a reply, and the assign function transforms our
# socket by adding the new count. Conceptually, we’re taking a socket and
# returning a transformed socket. This implementation bumps the count in
# :assigns by one, each time it’s called.

# handle_info is basically a loop. Each time, it returns the socket as the last tuple
# element for all callbacks. This way, we can maintain state. We simply push the ping event,
# and the JavaScript client picks up these events with the channel.on(event, callback) API.

# def handle_info(:ping, socket) do
#   count = socket.assigns[:count] || 1
#   push(socket, "ping", %{count: count})

#   {:noreply, assign(socket, :count, count + 1)}
# end
