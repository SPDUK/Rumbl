defmodule Rumbl.TestHelpers do
  alias Rumbl.{
    Accounts,
    Multimedia
  }

  @doc """
  Takes some attrs if no attrs are supplied it will have hard-coded sample data.
  Includes credential

  Registers a user and returns that user.
  """
  def user_fixture(attrs \\ %{}) do
    username = "user#{System.unique_integer([:positive])}"

    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: "Some User",
        username: username,
        credential: %{
          email: attrs[:email] || "#{username}@example.com",
          password: attrs[:password] || "supersecret"
        }
      })
      |> Accounts.register_user()

    user
  end

  @doc """
  Takes a user and attributes, if no attrs are supplied it will have hard-coded sample data.

  Creates a video and returns it.
  """
  def video_fixture(%Accounts.User{} = user, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        title: "A Title",
        url: "http://example.com",
        description: "a description"
      })

    {:ok, video} = Multimedia.create_video(user, attrs)
    video
  end
end
