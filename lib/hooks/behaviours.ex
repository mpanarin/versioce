defmodule Versioce.PreHook do
  @moduledoc """
  Behaviour for pre hooks in versioce.

  A hook can be defined by simply using `Versioce.PreHook` in a module:

      defmodule MyProj.Versioce.PreHook do
        use Versioce.PreHook

        def run(args) do
          IO.inspect(args)
        end
      end


  The `run/1` function will receive all arguments passed to the `bump` mix task.
  It can modify them and make required side-effects but it *should* return them
  as result of one hook is piped into next one.
  """

  @doc """
  A hook needs to implement `run` which receives
  a list of command line args for `bump` task.
  It should return them as well.
  """
	@callback run([String.t]) :: [String.t]

  @doc false
  defmacro __using__(_opts) do
	  quote do
	    @behaviour Versioce.PreHook
    end
  end
end

defmodule Versioce.PostHook do
  @moduledoc """
  Behaviour for post hooks in versioce.

  A hook can be defined by simply using `Versioce.PostHook` in a module:

      defmodule MyProj.Versioce.PreHook do
        use Versioce.PostHook

        def run(version) do
          IO.inspect(version)
        end
      end


  The `run/1` function will receive a version that project was bumped to.
  It can modify it and make required side-effects but it *should* return it
  as result of one hook is piped into next one.
  """

  @doc """
  A hook needs to implement `run` which receives
  a the new version of the project.
  It should return it as well.
  """
	@callback run(String.t) :: String.t

  @doc false
  defmacro __using__(_opts) do
	  quote do
	    @behaviour Versioce.PostHook
    end
  end
end
