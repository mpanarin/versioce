defmodule Versioce.Config.Macros do
  @moduledoc false

  defmacro value(key_or_path, default, doc \\ "")
  @doc """
  Macro to define a simple config value.
  """
  defmacro value(key, default, doc) when is_atom(key) do
    quote do
      @doc """
      Get config value for #{to_string(unquote(key))}

      #{unquote(doc)}

      You can configure it with:

          config :versioce,
            #{to_string(unquote(key))}: #{inspect(unquote(default))}

      Value for this configuration should either be a literal value or a function
      of 0 arity, that will return the value, ex:

          config :versioce,
            #{to_string(unquote(key))}: fn -> #{inspect(unquote(default))} end
      """
      def unquote(key)() do
        case Application.fetch_env(:versioce, unquote(key)) do
          {:ok, val} ->
            if is_function(val, 0) do
              apply(val, [])
            else
              val
            end
          :error -> unquote(default)
        end
      end
    end
  end

  @doc """
  Macro to define a config value taken by path
  """
  defmacro value(path, default, doc) when is_list(path) do
    h = List.first(path)
    t = List.last(path)
    quote do
      @doc """
      Get config value for #{to_string(unquote(t))}

      #{unquote(doc)}

      You can configure it with:

          config :versioce, #{inspect(unquote(h))},
            #{to_string(unquote(t))}: #{inspect(unquote(default))}

      Value for this configuration should either be a literal value or a function
      of 0 arity, that will return the value, ex:

          config :versioce, #{inspect(unquote(h))},
            #{to_string(unquote(t))}: fn -> #{inspect(unquote(default))} end
      """
      def unquote(t)() do
        case Application.fetch_env(:versioce, unquote(h)) do
          {:ok, val} ->
            case val[unquote(t)] do
              nil -> unquote(default)
              val ->
                if is_function(val, 0) do
                  apply(val, [])
                else
                  val
                end
            end
          :error -> unquote(default)
        end
      end
    end
  end

end
