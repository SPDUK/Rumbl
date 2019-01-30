defmodule RumblWeb.PageControllerTest do
  use RumblWeb.ConnCase

  # statement html_response(conn, 200) does the following:
  # • Asserts that the conn’s response was 200
  # • Asserts that the response content-type was text/html
  # • Returns the response body, allowing us to match on the contents

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Rumbl!"
  end
end
