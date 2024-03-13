defmodule ExM3U8.Tags.Part do
  @moduledoc """
  Structure representing a media part (partial segment/chunk).
  """
  @behaviour ExM3U8.Deserializer.AttributesDeserializer

  use ExM3U8.DSL, disable_loaders: [:int]
  use TypedStruct

  alias ExM3U8.Deserializer.AttributesDeserializer

  typedstruct enforce: true do
    field :duration, float()
    field :uri, String.t()
    field :independent?, boolean(), default: false

    field :byte_range, {size :: pos_integer(), offset :: non_neg_integer() | nil} | nil,
      default: nil
  end

  @impl true
  def deserialize(attrs) do
    AttributesDeserializer.deserialize_struct_fields(
      __MODULE__,
      &load/2,
      attrs
    )
  end

  load_attribute :duration,
    attribute: "DURATION",
    type: :float,
    allow_empty?: false

  load_attribute :uri,
    attribute: "URI",
    type: :string,
    allow_empty?: false

  load_attribute :independent?,
    attribute: "INDEPENDENT",
    type: :boolean,
    default: false

  defp load(:byte_range, attrs) do
    case Map.get(attrs, "BYTERANGE", nil) do
      nil -> {:ok, nil}
      byte_range -> ExM3U8.Helpers.parse_byte_range(byte_range)
    end
  end

  defimpl ExM3U8.Serializer do
    use ExM3U8.DSL

    require ExM3U8.Helpers

    alias ExM3U8.Helpers

    @impl true
    def serialize(%@for{} = data) do
      [Helpers.tag_prefix(), "PART:", Helpers.merge_attributes(data, &dump/1, &sorter/1)]
    end

    defp sorter(field) do
      Helpers.generate_sorter(field, [
        :duration,
        :uri,
        :independent?,
        :byte_range
      ])
    end

    dump_attribute :duration,
      attribute: "DURATION",
      skip_empty?: false

    dump_attribute :uri,
      attribute: "URI",
      quoted_string?: true,
      skip_empty?: false

    dump_attribute :independent?,
      attribute: "INDEPENDENT",
      empty_arg: false

    defp dump({:byte_range, nil}), do: []

    defp dump({:byte_range, {size, nil}}),
      do: ["BYTERANGE=", ~s("#{size}")]

    defp dump({:byte_range, {size, offset}}),
      do: ["BYTERANGE=", ~s("#{size}@#{offset}")]
  end
end
