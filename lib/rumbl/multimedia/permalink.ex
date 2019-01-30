defmodule Rumbl.Multimedia.Permalink do
  @moduledoc """
  Rumbl.Multimedia.Permalink is a custom type defined according to the Ecto.Type
  behavior. It expects us to define four functions:
  type
  cast
  dump
  load


  Returns the underlying Ecto type. In this case, we’re building on top
  of :id.
  Called when external data is passed into Ecto. It’s invoked when values
  in queries are interpolated or also by the cast function in changesets.
  Invoked when data is sent to the database.
  Invoked when data is loaded from the database.

  """
  @behaviour Ecto.Type
  def type, do: :id

  @doc """
  Matches out the integer using Integer.parse

  Integer.parse("13-hello")
  {13, "-hello"}
  """
  def cast(binary) when is_binary(binary) do
    case Integer.parse(binary) do
      {int, _} when int > 0 -> {:ok, int}
      _ -> :error
    end
  end

  def cast(integer) when is_integer(integer) do
    {:ok, integer}
  end

  def cast(_) do
    :error
  end

  def dump(integer) when is_integer(integer) do
    {:ok, integer}
  end

  def load(integer) when is_integer(integer) do
    {:ok, integer}
  end
end
