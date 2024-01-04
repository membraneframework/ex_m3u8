defmodule ExM3U8.MultivariantPlaylist do
  @moduledoc """
  Structure representing a multivariant playlist.
  """
  use TypedStruct

  alias ExM3U8.Tags.Variant

  typedstruct enforce: true do
    field :version, String.t(), default: nil
    field :independent_segments, boolean(), default: false

    field :variants, [Variant.t()]
  end

  defimpl ExM3U8.Serializer do
    @impl true
    def serialize(%@for{
          version: version,
          independent_segments: independent_segments,
          variants: variants
        }) do
      info_section = [
        "#EXTM3U"
      ]

      version =
        if version do
          ["#EXT-X-VERSION:#{version}"]
        else
          []
        end

      independent_segments =
        if independent_segments do
          ["#EXT-X-INDEPENDENT-SEGMENTS"]
        else
          []
        end

      streams = Enum.map(variants, &ExM3U8.Serializer.serialize/1)

      Enum.intersperse(info_section ++ version ++ independent_segments ++ streams, "\n")
    end
  end
end
