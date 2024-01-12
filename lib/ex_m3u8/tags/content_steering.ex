defmodule ExM3U8.Tags.ContentSteering do
  @moduledoc """
  Structure representing a content steering tag.
  """
  @behaviour ExM3U8.Deserializer.AttributesDeserializer

  use TypedStruct
  use ExM3U8.DSL, disable_loaders: [:int, :float, :boolean]

  alias ExM3U8.Deserializer.AttributesDeserializer

  typedstruct enforce: true do
    field :server_uri, String.t()
    field :pathway_id, String.t() | nil, default: nil
  end

  @impl true
  def deserialize(attrs) do
    AttributesDeserializer.deserialize_struct_fields(
      __MODULE__,
      &load/2,
      attrs
    )
  end

  load_attribute :server_uri,
    attribute: "SERVER-URI",
    allow_empty?: false

  load_attribute :pathway_id,
    attribute: "PATHWAY-ID",
    allow_empty?: true

  defimpl ExM3U8.Serializer do
    use ExM3U8.DSL

    require ExM3U8.Helpers

    alias ExM3U8.Helpers

    @impl true
    def serialize(%@for{} = data) do
      [
        [
          Helpers.tag_prefix(),
          "CONTENT-STEERING:",
          Helpers.merge_attributes(data, &dump/1, &sorter/1)
        ]
      ]
    end

    defp sorter(field) do
      Helpers.generate_sorter(field, [
        :server_uri,
        :pathway_id
      ])
    end

    dump_attribute :server_uri,
      attribute: "SERVER-URI",
      quoted_string?: true,
      skip_empty?: false

    dump_attribute :pathway_id,
      attribute: "PATHWAY-ID",
      quoted_string?: true,
      skip_empty?: true
  end
end
