defmodule RumblWeb.VideoControllerTest do
  use RumblWeb.ConnCase

  # logged out users
  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, Routes.video_path(conn, :new)),
        get(conn, Routes.video_path(conn, :index)),
        get(conn, Routes.video_path(conn, :show, "123")),
        get(conn, Routes.video_path(conn, :edit, "123")),
        put(conn, Routes.video_path(conn, :update, "123", %{})),
        post(conn, Routes.video_path(conn, :create, %{})),
        delete(conn, Routes.video_path(conn, :delete, "123"))
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end

  describe "with a logged-in user" do
    setup %{conn: conn, login_as: username} do
      user = user_fixture(username: username)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    # we’ll use tags anywhere we want to mark attributes for a
    # block of tests and describes to scope setups to a block of tests.

    # The tag module attribute accepts a keyword list or an atom. Passing an atom
    # is a shorthand way to set flag style options. For example @tag :logged_in is
    # equivalent to @tag logged_in: true. We rewrite our setup block to grab the config map,
    # which holds our metadata with the conn and tags which we use to populate our user fixture.

    # login_as is matched during setup as username
    @tag login_as: "max"
    test "lists all user's videos on index", %{conn: conn, user: user} do
      user_video = video_fixture(user, title: "funny cats")
      other_video = video_fixture(user_fixture(username: "other"), title: "another video")

      conn = get(conn, Routes.video_path(conn, :index))
      assert html_response(conn, 200) =~ ~r/Listing Videos/
      assert String.contains?(conn.resp_body, user_video.title)
      refute String.contains?(conn.resp_body, other_video.title)
    end
  end
end
