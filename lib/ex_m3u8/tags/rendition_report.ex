defmodule ExM3U8.Tags.RenditionReport do
  @moduledoc """
  Structure representing a rendition report. 
  """
  @behaviour ExM3U8.Deserializer.AttributesDeserializer

  use ExM3U8.DSL, disable_loaders: [:float, :boolean]
  use TypedStruct

  alias ExM3U8.Deserializer.AttributesDeserializer

  typedstruct enforce: true do
    field :uri, String.t()
    field :last_msn, integer()
    field :last_part, integer()
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
    allow_empty?: false

  load_attribute :last_msn,
    attribute: "LAST-MSN",
    allow_empty?: true,
    type: :int

  load_attribute :last_part,
    attribute: "LAST-PART",
    allow_empty?: true,
    type: :int

  defimpl ExM3U8.Serializer do
    use ExM3U8.DSL

    require ExM3U8.Helpers

    alias ExM3U8.Helpers

    @impl true
    def serialize(%@for{} = data) do
      [
        ExM3U8.Helpers.tag_prefix(),
        "RENDITION-REPORT:",
        Helpers.merge_attributes(data, &dump/1, &sorter/1)
      ]
    end

    defp sorter(field) do
      Helpers.generate_sorter(field, [
        :uri,
        :last_msn,
        :last_part
      ])
    end

    dump_attribute :uri,
      attribute: "URI",
      skip_empty?: false,
      quoted_string?: true

    dump_attribute :last_msn,
      attribute: "LAST-MSN",
      skip_empty?: false

    dump_attribute :last_part,
      attribute: "LAST-PART",
      skip_empty?: false
  end
end
