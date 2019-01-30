defmodule RumblWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller
  alias Rumbl.Accounts
  alias RumblWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  @doc """
  If a user is in the conn.assigns, we honor it, no
  matter how it got there. We have an improved testing story that doesn’t require
  us to write mocks or any other elaborate scaffolding.


  call checks if a :user_id is stored in the session. If one exists, we look it up and
  assign the result in the connection. assign is a function imported from Plug.Conn
  that slightly transforms the connection—in this case, storing the user (or nil)
  in conn.assigns. That way, the :current_user will be available in all downstream
  functions including controllers and views.

  """
  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    cond do
      user = conn.assigns[:current_user] ->
        conn

      user = user_id && Accounts.get_user(user_id) ->
        assign(conn, :current_user, user)

      true ->
        assign(conn, :current_user, nil)
    end
  end

  # If there’s a current user, we return the connection unchanged. Otherwise we
  # store a flash message and redirect back to our application root. We use halt(conn)
  # to stop any downstream transformations.
  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
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

  def login_by_email_and_pass(conn, email, given_pass) do
    case Accounts.authenticate_by_email_and_pass(email, given_pass) do
      {:ok, user} -> {:ok, login(conn, user)}
      {:error, :unauthorized} -> {:error, :unauthorized, conn}
      {:error, :not_found} -> {:error, :not_found, conn}
    end
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end
end
