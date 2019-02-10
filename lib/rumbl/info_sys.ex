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

  def compute(query, opts \\ []) do
    opts = Keyword.put_new(opts, :limit, 10)
    backends = opts[:backends] || @backends

    backends
    |> Enum.map(&async_query(&1, query, opts))
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
