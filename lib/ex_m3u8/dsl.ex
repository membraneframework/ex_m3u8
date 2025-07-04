defmodule ExM3U8.DSL do
  @moduledoc false

  defmacro __using__(opts) do
    disable_loaders =
      opts
      |> Keyword.get(:disable_loaders, [])
      |> Enum.map(&{&1, true})

    [
      quote do
        require unquote(__MODULE__)
        import unquote(__MODULE__)

        defp __dump_value(value) when is_binary(value), do: value
        defp __dump_value(value) when is_float(value), do: "#{Float.round(value, 3)}"
        defp __dump_value(value) when is_integer(value), do: "#{value}"
        defp __dump_value(true), do: "YES"
        defp __dump_value(false), do: "NO"
        defp __quoted_dump_value(value), do: ~s("#{__dump_value(value)}")
      end,
      unless disable_loaders[:string] do
        quote do
          defp __load_value(:string, value), do: {:ok, value}
        end
      end,
      unless disable_loaders[:boolean] do
        quote do
          defp __load_value(:boolean, "YES"), do: {:ok, true}
          defp __load_value(:boolean, "NO"), do: {:ok, false}
        end
      end,
      unless disable_loaders[:float] do
        quote do
          defp __load_value(:float, value) do
            case Float.parse(value) do
              {value, ""} -> {:ok, value}
              :error -> {:error, "invadlid float value"}
            end
          end
        end
      end,
      unless disable_loaders[:int] do
        quote do
          defp __load_value(:int, value) do
            case Integer.parse(value) do
              {value, ""} -> {:ok, value}
              :error -> {:error, "invadlid int value"}
            end
          end
        end
      end
    ]
  end

  defmacro dump_attribute(field, opts) do
    attribute = Keyword.fetch!(opts, :attribute)
    value = Keyword.get(opts, :value)

    skip_empty? = Keyword.get(opts, :skip_empty?, true)
    empty_arg = Keyword.get(opts, :empty_arg, nil)

    quoted_string? = Keyword.get(opts, :quoted_string?, false)

    attribute_prefix = "#{attribute}="

    skip_dump =
      if skip_empty? do
        quote do
          defp dump({unquote(field), unquote(empty_arg)}), do: []
        end
      else
        quote do
        end
      end

    dump_value_function = if quoted_string?, do: :__quoted_dump_value, else: :__dump_value

    proper_dump =
      if value do
        quote do
          defp dump({unquote(field), _value}) do
            [unquote(attribute_prefix), unquote(dump_value_function)(unquote(value))]
          end
        end
      else
        quote do
          defp dump({unquote(field), value}) do
            [unquote(attribute_prefix), unquote(dump_value_function)(value)]
          end
        end
      end

    [skip_dump, proper_dump]
  end

  defmacro load_attribute(field, opts) do
    attribute = Keyword.fetch!(opts, :attribute)
    allow_empty? = Keyword.get(opts, :allow_empty?, true)
    type = Keyword.get(opts, :type, :string)
    default = Keyword.get(opts, :default, nil)

    empty_value_result =
      if allow_empty? do
        quote do: {:ok, unquote(default)}
      else
        quote do:
                {:error,
                 "missing value (field: #{unquote(field) |> inspect()} opts: #{unquote(opts) |> inspect()})"}
      end

    quote do
      defp load(unquote(field), attrs) do
        case Map.fetch(attrs, unquote(attribute)) do
          {:ok, value} -> __load_value(unquote(type), value)
          :error -> unquote(empty_value_result)
        end
      end
    end
  end

  defmacro dump_tag(field, opts) do
    require ExM3U8.Helpers

    tag = Keyword.fetch!(opts, :tag)
    skip_empty? = Keyword.get(opts, :skip_empty?, true)
    empty_arg = Keyword.get(opts, :empty_arg, nil)

    skip_dump =
      if skip_empty? do
        quote do
          defp dump({unquote(field), unquote(empty_arg)}), do: []
        end
      else
        quote do
        end
      end

    proper_dump =
      quote do
        defp dump({unquote(field), value}) do
          [ExM3U8.Helpers.tag_prefix(), unquote(tag), ":", __dump_value(value)]
        end
      end

    [skip_dump, proper_dump]
  end

  defmacro ignore_dump(field) do
    quote do
      defp dump({unquote(field), _value}), do: []
    end
  end
end
