defmodule ExM3U8.Tags.Key do
  @moduledoc """
  Structure representing a key tag. 
  """
  @behaviour ExM3U8.Deserializer.AttributesDeserializer

  use TypedStruct
  use ExM3U8.DSL, disable_loaders: [:int, :float, :boolean]

  use TypedStruct

  alias ExM3U8.Deserializer.AttributesDeserializer

  typedstruct enforce: true do
    field :method, String.t()
    field :uri, String.t() | nil, default: nil
    field :iv, String.t() | nil, default: nil
    field :key_format, String.t() | nil, default: nil
    field :key_format_versions, String.t() | nil, default: nil
  end

  @impl true
  def deserialize(attrs) do
    AttributesDeserializer.deserialize_struct_fields(
      __MODULE__,
      &load/2,
      attrs
    )
  end

  load_attribute :method,
    attribute: "METHOD",
    allow_empty?: false

  load_attribute :uri,
    attribute: "URI",
    allow_empty?: true

  load_attribute :iv,
    attribute: "IV",
    allow_empty?: true

  load_attribute :key_format,
    attribute: "KEYFORMAT",
    allow_empty?: true

  load_attribute :key_format_versions,
    attribute: "KEYFORMATVERSIONS",
    allow_empty?: true

  defimpl ExM3U8.Serializer do
    use ExM3U8.DSL

    require ExM3U8.Helpers

    alias ExM3U8.Helpers

    @impl true
    def serialize(%@for{} = data) do
      [Helpers.tag_prefix(), "KEY:", Helpers.merge_attributes(data, &dump/1, &sorter/1)]
    end

    defp sorter(field) do
      Helpers.generate_sorter(field, [
        :method,
        :uri,
        :iv,
        :key_format,
        :key_format_versions
      ])
    end

    dump_attribute :method,
      attribute: "METHOD",
      quoted_string?: true,
      skip_empty?: false

    dump_attribute :uri,
      attribute: "URI",
      quoted_string?: true,
      skip_empty?: true

    dump_attribute :iv,
      attribute: "IV",
      quoted_string?: true,
      skip_empty?: true

    dump_attribute :key_format,
      attribute: "KEYFORMAT",
      quoted_string?: true,
      skip_empty?: true

    dump_attribute :key_format_versions,
      attribute: "KEYFORMATVERSIONS",
      quoted_string?: true,
      skip_empty?: true
  end
end
