defmodule ExM3U8.MediaPlaylist do
  @moduledoc """
  Structure representing a media playlist.
  """
  use TypedStruct

  alias ExM3U8.MediaPlaylist.Info

  alias ExM3U8.Tags.{
    Discontinuity,
    MediaInit,
    Part,
    PreloadHint,
    ProgramDateTime,
    RenditionReport,
    Segment
  }

  @type custom_tag_t :: struct()

  typedstruct enforce: true do
    field :info, Info.t()

    field :timeline, [
      Discontinuity.t()
      | MediaInit.t()
      | Segment.t()
      | Part.t()
      | PreloadHint.t()
      | ProgramDateTime.t()
      | RenditionReport.t()
      | custom_tag_t()
    ]
  end

  defimpl ExM3U8.Serializer do
    @impl true
    def serialize(%@for{info: info, timeline: timeline}) do
      info_section = [
        "#EXTM3U",
        ExM3U8.Serializer.serialize(info)
      ]

      timeline = Enum.map(timeline, &ExM3U8.Serializer.serialize/1)

      end_list =
        if info.end_list? do
          ["#EXT-X-ENDLIST"]
        else
          []
        end

      [Enum.intersperse(info_section ++ timeline, "\n"), end_list]
    end
  end
end
