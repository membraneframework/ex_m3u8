defmodule ExM3U8.MultivariantPlaylist do
  @moduledoc """
  Structure representing a multivariant playlist.
  """
  use TypedStruct

  alias ExM3U8.Tags

  @type custom_tag_t :: struct()

  typedstruct enforce: true do
    field :version, non_neg_integer(), default: nil
    field :independent_segments, boolean(), default: false

    field :items, [Tags.ContentSteering.t() | Tags.Media.t() | Tags.Stream.t() | custom_tag_t()]
  end

  defimpl ExM3U8.Serializer do
    @impl true
    def serialize(%@for{
          version: version,
          independent_segments: independent_segments,
          items: items
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

      items = Enum.map(items, &ExM3U8.Serializer.serialize/1)

      [Enum.intersperse(info_section ++ version ++ independent_segments ++ items, "\n"), "\n"]
    end
  end
end
