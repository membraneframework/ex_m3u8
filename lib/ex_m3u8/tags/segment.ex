defmodule ExM3U8.Tags.Segment do
  @moduledoc """
  Structure representing a media segment.
  """
  use TypedStruct

  typedstruct do
    field :duration, float()
    field :uri, String.t()
  end

  defimpl ExM3U8.Serializer do
    @impl true
    def serialize(%@for{duration: duration, uri: uri}) do
      ["#EXTINF:#{Float.ceil(duration, 5)},\n", uri]
    end
  end
end
