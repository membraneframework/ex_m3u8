defmodule ExM3U8.Helpers do
  @moduledoc false
  defmacro tag_prefix(), do: "#EXT-X-"

  defmacro generate_sorter(arg, fields) do
    clauses =
      fields
      |> Enum.with_index()
      |> Enum.map(fn {field, idx} ->
        {:->, [], [[field], idx]}
      end)

    {:case, [], [arg, [do: clauses]]}
  end

  @spec merge_attributes(struct(), (struct() -> [iodata()]), (atom() -> integer())) :: iodata()
  def merge_attributes(structure, dump_fun, attribute_sorter) do
    structure
    |> Map.from_struct()
    |> Enum.sort_by(fn {key, _value} -> attribute_sorter.(key) end)
    |> Enum.map(dump_fun)
    |> Enum.reject(&match?([], &1))
    |> Enum.intersperse(",")
  end

  @spec merge_tags(struct(), (struct() -> [iodata()]), (atom() -> integer())) :: iodata()
  def merge_tags(structure, dump_fun, tag_sorter) do
    structure
    |> Map.from_struct()
    |> Enum.sort_by(fn {key, _value} -> tag_sorter.(key) end)
    |> Enum.map(dump_fun)
    |> Enum.reject(&match?([], &1))
    |> Enum.intersperse("\n")
  end

  @spec quoted_string(String.t()) :: String.t()
  def quoted_string(value), do: ~s("#{value}")

  @spec parse_byte_range(String.t()) ::
          {:ok, {size :: non_neg_integer(), offset :: non_neg_integer() | nil}}
          | {:error, String.t()}
  def parse_byte_range(value) do
    error = {:error, "invalid byte range"}

    case String.split(value, "@", parts: 2) do
      [size, offset] ->
        case {Integer.parse(size), Integer.parse(offset)} do
          {{size, ""}, {offset, ""}} -> {:ok, {size, offset}}
          _other -> error
        end

      [size] ->
        case Integer.parse(size) do
          {size, ""} -> {:ok, {size, nil}}
          :error -> error
        end

      _other ->
        error
    end
  end
end
