defmodule Versioce.PreHook do
  @moduledoc """
  Behaviour for pre hooks in versioce.

  A hook can be defined by simply using `Versioce.PreHook` in a module:

      defmodule MyProj.Versioce.PreHook do
        use Versioce.PreHook

        def run(args) do
          IO.inspect(args)
          {:ok, args}
        end
      end


  The `run/1` function will receive all arguments passed to the `bump` mix task.
  It can modify them and make required side-effects but it *should* return them
  of form `{:ok, args}` as result of one hook is piped into the next one, unless
  `{:error, reason}` is returned, then the hook pipe is halted.
  """

  @doc """
  A hook needs to implement `run` which receives
  a list of command line args for `bump` task.
  It should return them in form `{:ok, args} | {:error, reason}`
  """
  @callback run([String.t()]) :: {:ok, [String.t()]} | {:error, String.t()}

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
          {:ok, version}
        end
      end


  The `run/1` function will receive a version that project was bumped to.
  It can modify it and make required side-effects but it *should* return it
  of form `{:ok, version}` as result of one hook is piped into the next one,
  unless `{:error, reason}` is returned, then the hook pipe is halted.
  """

  @doc """
  A hook needs to implement `run` which receives
  the new version of the project.
  It should return it in form `{:ok, version} | {:error, reason}`
  """
  @callback run(String.t()) :: {:ok, String.t()} | {:error, String.t()}

  @doc false
  defmacro __using__(_opts) do
    quote do
      @behaviour Versioce.PostHook
    end
  end
end

defmodule Versioce.OK do
  @moduledoc false

  @type ok_tuple :: {:ok, any} | {:error, any}

  @spec bind(ok_tuple, fun) :: ok_tuple()
  def bind({:ok, value}, func), do: func.(value)
  def bind({:error, reason}, _), do: {:error, reason}

  @spec unit(any) :: ok_tuple()
  def unit({:ok, _} = value), do: value
  def unit({:error, _} = value), do: value
  def unit(value), do: {:ok, value}
end

defmodule Versioce.Hooks do
  @moduledoc false

  @spec run(any, [module()]) :: Versioce.OK.ok_tuple()
  def run(params, []), do: Versioce.OK.unit(params)

  def run(params, [h | tail]) do
    params
    |> Versioce.OK.unit()
    |> Versioce.OK.bind(&h.run/1)
    |> run(tail)
  end
end
