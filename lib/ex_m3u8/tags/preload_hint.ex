defmodule ExM3U8.Tags.PreloadHint do
  @moduledoc """
  Structure representing a preload hint present in a media playlist.
  """
  use TypedStruct

  typedstruct enforce: true do
    field :type, :part | :map, default: :part
    field :uri, String.t()
    field :byte_range_start, non_neg_integer() | nil
    field :byte_range_length, non_neg_integer() | nil
  end
end
