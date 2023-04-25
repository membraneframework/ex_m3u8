defmodule ExM3U8.Tags.Discontinuity do
  @moduledoc """
  Structure representing media discontinuity.
  """
  use TypedStruct

  typedstruct enforce: true do
  end

  defimpl ExM3U8.Serializer do
    use ExM3U8.DSL

    require ExM3U8.Helpers

    @impl true
    def serialize(_data) do
      [ExM3U8.Helpers.tag_prefix(), "DISCONTINUITY"]
    end
  end
end
