defmodule RumblWeb.UserSocket do
  use Phoenix.Socket

  # Transports route events into your UserSocket, where they’re dispatched into
  # your channels based on topic patterns that you declare with the channel macro.
  # Our videos:* convention categorizes topics with a resource name, followed by
  # a resource ID.

  channel "videos:*", RumblWeb.VideoChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.

  # 2 weeks
  @max_age 2 * 7 * 24 * 60 * 60
  @doc """
  Any :params we pass to the socket constructor in socket.js will be used here in connect as the first argument.

  We pass a max_age, ensuring that tokens are only valid for a certain period of time
  If the token is valid, we receive the user_id and store it in our socket.assigns while returning {:ok, socket}

  If the token is invalid, we return :error, denying the connection attempt by the client.


  """
  def connect(%{"token" => token}, socket) do
    case Phoenix.Token.verify(
           socket,
           "user socket",
           token,
           max_age: @max_age
         ) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}

      {:error, _reason} ->
        :error
    end
  end

  def connect(_params, _socket), do: :error
  def id(socket), do: "users_socket:#{socket.assigns.user_id}"

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     RumblWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
end
