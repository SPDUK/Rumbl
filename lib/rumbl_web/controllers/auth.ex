defmodule RumblWeb.Auth do
  import Plug.Conn
  alias Rumbl.Accounts

  def init(opts), do: opts

  @doc """
  call checks if a :user_id is stored in the session. If one exists, we look it up and
  assign the result in the connection. assign is a function imported from Plug.Conn
  that slightly transforms the connection—in this case, storing the user (or nil)
  in conn.assigns. That way, the :current_user will be available in all downstream
  functions including controllers and views.

  """
  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && Accounts.get_user(user_id)
    assign(conn, :current_user, user)
  end

  @doc """
  The Plug.Conn struct has a field called assigns. We call setting a
  value in that structure an assign. Our function stores the given user as the
  :current_user assign, puts the user ID in the session, and finally configures the
  session, setting the :renew option to true.

  renew: true  stops session fixations attacks.
  """
  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end
end
