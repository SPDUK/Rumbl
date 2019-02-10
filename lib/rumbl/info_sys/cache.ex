defmodule Rumbl.InfoSys.Cache do
  @moduledoc """
    Starts out with one cache, but creates other caches as needed.
  """
  use GenServer

  @doc """
    Ensure a name key is present as the name of the module if it is not passed in.
  """
  def start_link(opts) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  @doc """
    Converts out genserver's name to a table name.
    passing in a key:value pair as arguments we turn that to a tuple. {key, value}

    for example we call:  :ets.insert("hello_cache", {"hello", "world"})
    Matching on true to ensure it was successful, then return :ok
  """
  def put(name \\ __MODULE__, key, value) do
    true = :ets.insert(tab_name(name), {key, value})
    :ok
  end

  @doc """
    Wraps the API of ETS
    Uses 1-based index!
  """
  def fetch(name \\ __MODULE__, key) do
    {:ok, :ets.lookup_element(tab_name(name), key, 2)}
  rescue
    ArgumentError -> :error
  end

  @clear_interval :timer.seconds(60)
  def init(opts) do
    state = %{
      interval: opts[:clear_interval] || @clear_interval,
      # holds a pid for the timer
      timer: nil,
      table: new_table(opts[:name])
    }

    {:ok, schedule_clear(state)}
  end

  @doc """
    Clears all the ets tables for that state, then schedules another clear
  """
  def handle_info(:clear, state) do
    :ets.delete_all_objects(state.table)
    {:noreply, schedule_clear(state)}
  end

  # uses Process.send_after to send a message in the future that clears cache
  defp schedule_clear(state) do
    %{state | timer: Process.send_after(self(), :clear, state.interval)}
  end

  # create and name our ETS table with new_table. ETS tables are owned by a
  # single process, and the table’s existence lives and dies with that of its owner.
  # Called during init
  # options:
  # :set is a type of ETS table that acts as key:value store
  # :named_table let's us locate it by the name, :public lets other processes read/write values
  # :read/write_concurrency maximizes performance for concurrent workloads.
  defp new_table(name) do
    name
    |> tab_name()
    |> :ets.new([:set, :named_table, :public, read_concurrency: true, write_concurrency: true])
  end

  defp tab_name(name), do: :"#{name}_cache"
end
