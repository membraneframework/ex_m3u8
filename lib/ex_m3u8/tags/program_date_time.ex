defmodule ExM3U8.Tags.ProgramDateTime do
  @moduledoc """
  Structure representing program date time of the following media segment/chunk.
  """
  use TypedStruct

  typedstruct enforce: true do
    field :date, DateTime.t()
  end

  defimpl ExM3U8.Serializer do
    use ExM3U8.DSL

    require ExM3U8.Helpers

    @impl true
    def serialize(%@for{date: date}) do
      [ExM3U8.Helpers.tag_prefix(), "PROGRAM-DATE-TIME:", DateTime.to_iso8601(date)]
    end
  end
end
