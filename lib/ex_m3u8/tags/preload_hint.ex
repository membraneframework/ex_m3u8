defmodule ExM3U8.Tags.PreloadHint do
  @moduledoc """
  Structure representing a preload hint present in a media playlist.
  """
  @behaviour ExM3U8.Deserializer.AttributesDeserializer

  use ExM3U8.DSL, disable_loaders: [:float, :boolean]
  use TypedStruct

  alias ExM3U8.Deserializer.AttributesDeserializer

  typedstruct enforce: true do
    field :type, :part | :map, default: :part
    field :uri, String.t()
    field :byterange_start, non_neg_integer() | nil, default: nil
    field :byterange_length, non_neg_integer() | nil, default: nil
  end

  @impl true
  def deserialize(attrs) do
    AttributesDeserializer.deserialize_struct_fields(
      __MODULE__,
      &load/2,
      attrs
    )
  end

  load_attribute :uri,
    attribute: "URI",
    type: :string,
    allow_empty?: false

  load_attribute :byterange_start,
    attribute: "BYTERANGE-START",
    type: :int,
    allow_empty?: true,
    default: nil

  load_attribute :byterange_length,
    attribute: "BYTERANGE-LENGTH",
    type: :int,
    allow_empty?: true,
    default: nil

  defp load(:type, attrs) do
    case Map.fetch(attrs, "TYPE") do
      {:ok, "PART"} -> {:ok, :part}
      {:ok, "MAP"} -> {:ok, :map}
      {:ok, value} -> {:error, "invalid preloat hint type: #{value}"}
      :error -> {:error, "value missing"}
    end
  end

  defimpl ExM3U8.Serializer do
    use ExM3U8.DSL

    require ExM3U8.Helpers

    alias ExM3U8.Helpers

    @impl true
    def serialize(%@for{} = data) do
      [Helpers.tag_prefix(), "PRELOAD-HINT:", Helpers.merge_attributes(data, &dump/1, &sorter/1)]
    end

    defp sorter(field) do
      Helpers.generate_sorter(field, [
        :type,
        :uri,
        :byterange_start,
        :byterange_length
      ])
    end

    dump_attribute :uri,
      attribute: "URI",
      quoted_string?: true,
      skip_empty?: false

    dump_attribute :byterange_start,
      attribute: "BYTERANGE-START",
      skip_empty?: true

    dump_attribute :byterange_length,
      attribute: "BYTERANGE-LENGTH",
      skip_empty?: true

    defp dump({:type, type}),
      do: [
        "TYPE=",
        "#{type |> Atom.to_string() |> String.upcase()}"
      ]
  end
end
