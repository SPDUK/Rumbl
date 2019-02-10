defmodule Rumbl.InfoSys do
  @moduledoc """
    End users will send a request, and wait for results.
    If a result doesn’t come back from one of our services,
    we’ll just discard the result and the supervisor will kill it.
  """
  alias Rumbl.InfoSys
  @backends [InfoSys.Wolfram]

  defmodule Result do
    defstruct score: 0, text: nil, url: nil, backend: nil
  end

  @doc """
    Waits for results, when recieving sorts it sorts them by score and report the top ones.

    Uses yield_many to get the results of all the tasks (api fetches) that have finished,
    killing any tasks that aren't finished yet.
  """
  def compute(query, opts \\ []) do
    timeout = opts[:timeout] || 10_000
    opts = Keyword.put_new(opts, :limit, 10)
    backends = opts[:backends] || @backends

    backends
    |> Enum.map(&async_query(&1, query, opts))
    |> Task.yield_many(timeout)
    |> Enum.map(fn {task, res} -> res || Task.shutdown(task, :brutal_kill) end)
    |> Enum.flat_map(fn
      {:ok, results} ->
        results

      _ ->
        []
    end)
    |> Enum.sort(&(&1.score >= &2.score))
    |> Enum.take(opts[:limit])
  end

  # invoking a task that needs a module, function, and arguments for the new task
  # async_nolink spawns off the new task in a new process and calls the function we specify
  # async_nolink isolates the task from the caller, so clients can query backends,
  # without needing to worry about crashes
  defp async_query(backend, query, opts) do
    Task.Supervisor.async_nolink(InfoSys.TaskSupervisor, backend, :compute, [query, opts],
      shutdown: :brutal_kill
    )
  end
end
