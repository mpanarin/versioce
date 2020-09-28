defmodule Versioce.PreHook do
	@callback run([String.t]) :: [String.t]

  defmacro __using__(_opts) do
	  quote do
	    @behaviour Versioce.PreHook
    end
  end
end

defmodule Versioce.PostHook do
	@callback run(String.t) :: String.t

  defmacro __using__(_opts) do
	  quote do
	    @behaviour Versioce.PostHook
    end
  end
end
