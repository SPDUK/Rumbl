defmodule Rumbl.InfoSys.Supervisor do
  @moduledoc """
    We use Supervisor to prepare our code to use the Supervisor
    API. We’re actually implementing a behaviour, which is an API contract.
    Supervisors need to specify a start_link function to start the supervisor, and an
    init function to initialize each of the workers.
  """
  use Supervisor
  alias Rumbl.InfoSys

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
    tells OTP how to start and stop a supervisor with its children.

    using rest_for_one it will restart the first child that crashes, then the rest of the tree that
    start after that child.

    If the cache crashes, all children will be restarted
    If anything after the cache crashes, the cache stays alive and the rest are restarted.
  """
  def init(_opts) do
    children = [
      InfoSys.Cache,
      {Task.Supervisor, name: InfoSys.TaskSupervisor}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
