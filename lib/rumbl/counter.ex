defmodule Rumbl.Counter do
  use GenServer

  # async, calls handle_cast
  def inc(pid), do: GenServer.cast(pid, :inc)
  def dec(pid), do: GenServer.cast(pid, :dec)

  @doc """
   When we want to send synchronous messages that return, calls handle_call
   the state of the server, we use GenServer.call
  """
  def val(pid) do
    GenServer.call(pid, :val)
  end

  @doc """
    We have to tweak the start_link to start a GenServer, giving it the current module
    name and the counter. This function spawns a new process and invokes the
    Rumbl.Counter.init function inside this new process to set up its initial state.
  """
  def start_link(initial_val) do
    GenServer.start_link(__MODULE__, initial_val)
  end

  def init(initial_val) do
    {:ok, initial_val}
  end

  # explicitly tell OTP when to send a reply and when not to using :noreply and :reply
  def handle_cast(:inc, val) do
    {:noreply, val + 1}
  end

  def handle_cast(:dec, val) do
    {:noreply, val - 1}
  end

  def handle_call(:val, _from, val) do
    {:reply, val, val}
  end
end
