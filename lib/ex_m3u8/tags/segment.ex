defmodule ExM3U8.Tags.Segment do
  @moduledoc """
  Structure representing a media segment.
  """
  use TypedStruct
  use ExM3U8.DSL, disable_loaders: [:int, :float, :boolean]

  typedstruct enforce: false do
    field :duration, float()
    field :uri, String.t()
    field :video_layout, String.t() | nil
  end

  defimpl ExM3U8.Serializer do
    use ExM3U8.DSL
    require ExM3U8.Helpers
    alias ExM3U8.Helpers

    @impl true
    def serialize(%@for{duration: duration, uri: uri, video_layout: video_layout}) do
      duration =
        if is_float(duration) do
          Float.ceil(duration, 3)
        else
          duration
        end

      if video_layout do
        ["#EXTINF:#{duration},REQ-VIDEO-LAYOUT=#{Helpers.quoted_string(video_layout)}\n", uri]
      else
        ["#EXTINF:#{duration},\n", uri]
      end
    end

    dump_attribute :video_layout,
      attribute: "REQ-VIDEO-LAYOUT",
      quoted_string?: true,
      skip_empty?: false
  end
end
