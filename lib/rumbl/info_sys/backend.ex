defmodule Rumbl.InfoSys.Backend do
  # behaviours
  @callback name() :: String.t()
  @callback compute(query :: String.t(), opts :: Keyword.t()) ::
              [Rumbl.InfoSys.Result.t()]
end
