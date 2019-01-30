# We’re implementing the Phoenix.Param protocol for the Rumbl.Multimedia.Video struct.
# The protocol requires us to implement the to_param function, which receives
# the video struct itself. We pattern-match on the video slug and ID and use it
# to build a string as our slug. Our param.ex file will serve as a home for other
# protocol implementations as we continue building our application.

defimpl Phoenix.Param, for: Rumbl.Multimedia.Video do
  def to_param(%{slug: slug, id: id}) do
    "#{id}-#{slug}"
  end
end
