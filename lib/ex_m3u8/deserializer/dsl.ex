defmodule ExM3U8.Deserializer.DSL do
  @moduledoc false
  @tag_prefix "#EXT-X-"

  defmacro match_tag(tag) do
    tag = @tag_prefix <> tag <> ":"

    quote do
      unquote(tag)
    end
  end

  defmacro parse_tag(tag, do: block) do
    tag = @tag_prefix <> tag <> ":"

    block = wrap_do_block(block)

    quote do
      defp do_parse([unquote(tag) <> value | lines], acc, opts) do
        with {:ok, tag_name, new_value} <- unquote(block).(value) do
          do_parse(lines, [{tag_name, new_value} | acc], opts)
        end
      end
    end
  end

  defmacro parse_raw(prefix, do: block) do
    block = wrap_raw_do_block(block)

    quote do
      defp do_parse([unquote(prefix) <> value | lines], acc, opts) do
        with {:ok, tag_name, new_value, lines} <- unquote(block).(value, lines) do
          do_parse(lines, [{tag_name, new_value} | acc], opts)
        end
      end
    end
  end

  defp wrap_do_block(body) do
    quote do
      fn var!(value) ->
        unquote(body)
      end
    end
  end

  defp wrap_raw_do_block(body) do
    quote do
      fn var!(value), var!(lines) ->
        unquote(body)
      end
    end
  end
end
