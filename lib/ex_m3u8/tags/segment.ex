defmodule ExM3U8.Tags.Segment do
  @moduledoc """
  Structure representing a media segment.

  `sequence_number` is the Media Sequence Number of the segment, resolved by the
  deserializer from `EXT-X-MEDIA-SEQUENCE`. The serializer ignores it.
  """
  use TypedStruct

  typedstruct enforce: true do
    field :duration, float()
    field :uri, String.t()
    field :sequence_number, non_neg_integer() | nil, default: nil
  end

  defimpl ExM3U8.Serializer do
    @impl true
    def serialize(%@for{duration: duration, uri: uri}) do
      duration =
        if is_float(duration) do
          Float.round(duration, 6)
        else
          duration
        end

      ["#EXTINF:#{duration},\n", uri]
    end
  end
end
