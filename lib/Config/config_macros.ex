defmodule Versioce.Config.Macros.Description do
  @moduledoc false
  defstruct description: "", example: nil

  @type t :: __MODULE__
end

defmodule Versioce.Config.Macros do
  @moduledoc false
  alias Versioce.Config.Macros.Description

  @doc """
  Macro to define a simple config value or by path.
  `path` is a list of atoms with `key` at the end, ex:

      [:level1, :level2, :key]

  `key`s should be unique for their module.
  When called, value will either be picked from Application or default.

  In description the example value can be set via `:example` key. If not set, the default
  value will be used as an example one.

  ex.:

      value :foo, "default value", %Description{doc: "description", example: "example value"}
      value [:spam, :eggs], %{}, %Description{doc: "description"}
  """
  defmacro value(key_or_path, default, doc \\ %Description{description: "", example: ""})

  defmacro value(key, default, doc) when is_atom(key) do
    quote do
      @doc """
      Get config value for #{to_string(unquote(key))}

      Default value: #{inspect(unquote(default))}

      #{unquote(doc).description}

      You can configure it with:

          config :versioce,
            #{to_string(unquote(key))}: #{inspect(if example = unquote(doc).example, do: example, else: unquote(default))}

      Value for this configuration should either be a literal value or a function
      of 0 arity, that will return the value, ex:

          config :versioce,
            #{to_string(unquote(key))}: fn -> #{inspect(if example = unquote(doc).example, do: example, else: unquote(default))} end
      """
      def unquote(key)() do
        case Application.fetch_env(:versioce, unquote(key)) do
          {:ok, val} ->
            if is_function(val, 0) do
              val.()
            else
              val
            end

          _ ->
            unquote(default)
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

      Default value: #{inspect(unquote(default))}

      #{unquote(doc).description}

      You can configure it with:

          config :versioce, #{inspect(unquote(h))},
            #{to_string(unquote(t))}: #{inspect(if example = unquote(doc).example, do: example, else: unquote(default))}

      Value for this configuration should either be a literal value or a function
      of 0 arity, that will return the value, ex:

          config :versioce, #{inspect(unquote(h))},
            #{to_string(unquote(t))}: fn -> #{inspect(if example = unquote(doc).example, do: example, else: unquote(default))} end
      """
      def unquote(t)() do
        with {:ok, val} <- Application.fetch_env(:versioce, unquote(h)),
             {:ok, val} <- Keyword.fetch(val, unquote(t)) do
          if is_function(val, 0) do
            val.()
          else
            val
          end
        else
          _ -> unquote(default)
        end
      end
    end
  end
end
