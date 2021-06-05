defmodule Versioce.Config.Macros do
  @moduledoc false

  @doc """
  Macro to define a simple config value or by path.
  `path` is a list of atoms with `key` at the end, ex:

      [:level1, :level2, :key]

  `key`s should be unique for their module.
  When called, value will either be picked from Application or default.

  ex.:

      value :foo, "default value", "description"
      value [:spam, :eggs], %{}, "another description"
  """
  defmacro value(key_or_path, default, doc \\ "")

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
        with {:ok, val} <- Application.fetch_env(:versioce, unquote(key)) do
          cond do
            is_function(val, 0) -> apply(val, [])
            true -> val
          end
        else
          _ -> unquote(default)
        end
      end
    end
  end

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
        with {:ok, val} <- Application.fetch_env(:versioce, unquote(h)),
             {:ok, val} <- Keyword.fetch(val, unquote(t)) do
          cond do
            is_function(val, 0) -> apply(val, [])
            true -> val
          end
        else
          _ -> unquote(default)
        end
      end
    end
  end
end
