defmodule ExM3U8.Tags.Segment do
  @moduledoc """
  Structure representing a media segment.
  """
  use TypedStruct

  typedstruct enforce: true do
    field :duration, float()
    field :uri, String.t()
  end

  defimpl ExM3U8.Serializer do
    @impl true
    def serialize(%@for{duration: duration, uri: uri}) do
      duration =
        if is_float(duration) do
          Float.ceil(duration, 3)
        else
          duration
        end

      ["#EXTINF:#{duration},\n", uri]
    end
  end
end
