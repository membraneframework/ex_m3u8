defmodule ExM3U8.Tags.Skip do
  @moduledoc """
  Structure representing a media segment.
  """
  @behaviour ExM3U8.Deserializer.AttributesDeserializer

  use ExM3U8.DSL, disable_loaders: [:string, :float, :boolean]
  use TypedStruct

  alias ExM3U8.Deserializer.AttributesDeserializer

  typedstruct enforce: true do
    field :skipped_segments, non_neg_integer()
  end

  @impl true
  def deserialize(attrs) do
    AttributesDeserializer.deserialize_struct_fields(
      __MODULE__,
      &load/2,
      attrs
    )
  end

  load_attribute :skipped_segments,
    attribute: "SKIPPED-SEGMENTS",
    type: :int,
    allow_empty?: false

  defimpl ExM3U8.Serializer do
    require ExM3U8.Helpers

    alias ExM3U8.Helpers

    @impl true
    def serialize(%@for{skipped_segments: n}) do
      [Helpers.tag_prefix(), "SKIP:SKIPPED-SEGMENTS=#{n}"]
    end
  end
end
