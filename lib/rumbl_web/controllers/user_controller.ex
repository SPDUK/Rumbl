defmodule RumblWeb.UserController do
  use RumblWeb, :controller
  alias Rumbl.Accounts
  alias Rumbl.Accounts.User

  # no need to check if halted, plugs automatically check between every plug action, if halted then it just returns the current connection, else it will continue

  # When we changed the index action, we had to explicitly check if the connection halted
  # or not, before acting on it. Plug pipelines explicitly check for halted: true between
  # every plug invocation, so the halting concern is neatly solved by Plug.

  plug :authenticate when action in [:index, :show]

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user(id)
    render(conn, "show.html", user: user)
  end

  def new(conn, _params) do
    changeset = Accounts.change_registration(%User{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  @doc """
  Creates an account and instantly logs it in.
  """
  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> RumblWeb.Auth.login(user)
        |> put_flash(:info, "#{user.name} Created!")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  # If there’s a current user, we return the connection unchanged. Otherwise we
  # store a flash message and redirect back to our application root. We use halt(conn)
  # to stop any downstream transformations.
  defp authenticate(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end
