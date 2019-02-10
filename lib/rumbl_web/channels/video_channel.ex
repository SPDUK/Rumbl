defmodule RumblWeb.VideoChannel do
  @moduledoc """
  Allows connections through join and also let users disconnect and send events.

  Sockets will hold all of the state for a given conversation.
  Each socket can hold its own state in the socket.assigns ield, which typically holds a map.
  """
  alias Rumbl.{Accounts, Multimedia}
  alias RumblWeb.AnnotationView

  use RumblWeb, :channel

  @doc """
  Composes a response for when a user joins the channel.

  We list the current video's annotations, and then pipe that into a render_many that will return
  all of the annotations in json.

  Also adds the video ID from our topic to socket.assigns.
  """
  def join("videos:" <> video_id, params, socket) do
    last_seen_id = params["last_seen_id"] || 0
    video_id = String.to_integer(video_id)
    video = Multimedia.get_video!(video_id)

    annotations =
      video
      |> Multimedia.list_annotations(last_seen_id)
      |> Phoenix.View.render_many(AnnotationView, "annotation.json")

    {:ok, %{annotations: annotations}, assign(socket, :video_id, video_id)}
  end

  @doc """
  Ensure all incoming events have a current_user.
  """
  def handle_in(event, params, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  @doc """
  Call annotate_video function, on success we broadcast to all subscribers

  Otherwise return a response with the changeset errors

  After a broadcast we acknowledge the success by returning {:reply, :ok, socket}
  """
  def handle_in("new_annotation", params, user, socket) do
    case Multimedia.annotate_video(user, socket.assigns.video_id, params) do
      {:ok, annotation} ->
        broadcast_annotation(socket, user, annotation)
        Task.start_link(fn -> compute_additional_info(annotation, socket) end)
        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  defp broadcast_annotation(socket, user, annotation) do
    broadcast!(socket, "new_annotation", %{
      id: annotation.id,
      user: RumblWeb.UserView.render("user.json", %{user: user}),
      body: annotation.body,
      at: annotation.at
    })
  end

  defp compute_additional_info(annotation, socket) do
    for result <- Rumbl.InfoSys.compute(annotation.body, limit: 1, timeout: 10_000) do
      backend_user = Accounts.get_user_by(username: result.backend.name())
      attrs = %{url: result.url, body: result.text, at: annotation.at}

      case Multimedia.annotate_video(backend_user, annotation.video_id, attrs) do
        {:ok, info_ann} -> broadcast_annotation(socket, backend_user, info_ann)
        {:error, _changeset} -> :ignore
      end
    end
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
