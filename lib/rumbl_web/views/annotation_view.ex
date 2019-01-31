defmodule RumblWeb.AnnotationView do
  use RumblWeb, :view

  @doc """
  Renders a single annotation, but also renders a single user inside it as user.
  """
  def render("annotation.json", %{annotation: annotation}) do
    %{
      id: annotation.id,
      body: annotation.body,
      at: annotation.at,
      user: render_one(annotation.user, RumblWeb.UserView, "user.json")
    }
  end
end
