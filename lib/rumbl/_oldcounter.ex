defmodule Rumbl.OldCounter do
  # only exist to send messages to our server process (async, sends without waiting for reply)
  def inc(pid), do: send(pid, :inc)
  def dec(pid), do: send(pid, :dec)

  @doc """
     must send a request for the value of the counter and await the response.
     (sync, blocks the caller proccess while waiting for a response)
  """
  def val(pid, timeout \\ 5000) do
    # associate a response with the current request using a globally unique reference
    ref = make_ref()
    # send message to our counter (listen) which will return a message we catch with receive
    send(pid, {:val, self(), ref})

    # rather than rebinding the ref we use the previous one from make_ref()
    # only matches that exact ref, make sure to only match responses related to this explicit request
    receive do
      {^ref, val} -> val
    after
      timeout -> exit(:timeout)
    end
  end

  @doc """
  Takes in an initial value, it's only job is to spawn a process and return {:ok, pid} where pid idenfities the spawned process
  The spawned process calls the private function named listen, which listens for messages and processes them.
  """
  def start_link(initial_val) do
    {:ok, spawn_link(fn -> listen(initial_val) end)}
  end

  # Takes in a value which is either a single atom :inc or :dec, or it will be a tuple that matches {:val, sender, ref}.
  # If we get :inc or :dec we just update the state of value with +1.
  # Otherwise we send back a message to the sender
  defp listen(val) do
    receive do
      :inc ->
        listen(val + 1)

      :dec ->
        listen(val - 1)

      {:val, sender, ref} ->
        send(sender, {ref, val})
        listen(val)
    end
  end
end
