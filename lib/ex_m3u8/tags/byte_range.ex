defmodule ExM3U8.Tags.ByteRange do
  @moduledoc """
  Structure representing byte range of the following media segment/chunk.
  """
  use TypedStruct

  typedstruct enforce: true do
    field :length, non_neg_integer()
    field :offset, non_neg_integer() | nil, default: nil
  end

  defimpl ExM3U8.Serializer do
    use ExM3U8.DSL

    require ExM3U8.Helpers

    @impl true
    def serialize(%@for{length: length, offset: offset}) do
      offset =
        if offset do
          "@#{offset}"
        else
          ""
        end

      [ExM3U8.Helpers.tag_prefix(), "BYTERANGE:", "#{length}#{offset}"]
    end
  end
end
