defmodule ExM3U8.Deserializer.AttributesList do
  @moduledoc false
  import NimbleParsec

  defparsec(:do_parse, parsec(:attributes_list) |> eos())

  attribute =
    unwrap_and_tag(ascii_string([?A..?Z, ?-], min: 1), :key)
    |> ignore(string("="))
    |> choice([
      # non-quoted attribute value
      ascii_string([?a..?z, ?A..?Z, ?0..?9, ?., ?-], min: 1)
      |> unwrap_and_tag(:value),
      # quoted attribute value
      ignore(ascii_char([?"]))
      |> ascii_string([not: ?"], min: 1)
      |> ignore(ascii_char([?"]))
      |> unwrap_and_tag(:value)
    ])
    |> tag(:attribute)

  attributes_list =
    repeat(
      attribute
      |> optional(ignore(string(",")))
    )

  defcombinatorp(
    :attributes_list,
    attributes_list
  )

  @spec parse(String.t()) :: {:ok, map()} | :error
  def parse(payload) do
    case do_parse(payload) do
      {:ok, values, _1, _2, _3, _4} ->
        {:ok,
         Map.new(values, fn {:attribute, [key: key, value: value]} ->
           {key, value}
         end)}

      _other ->
        :error
    end
  end
end
