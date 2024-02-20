defmodule ExM3U8.Tags.ByteRangeTest do
  use ExUnit.Case

  import ExM3U8.TestUtils, only: [serialize: 1]

  test "serialize byte range" do
    byte_range = %ExM3U8.Tags.ByteRange{
      length: 5,
      offset: nil
    }

    assert """
           #EXT-X-BYTERANGE:5
           """
           |> String.trim_trailing() == serialize(byte_range)

    byte_range = %ExM3U8.Tags.ByteRange{
      length: 5,
      offset: 111
    }

    assert """
           #EXT-X-BYTERANGE:5@111
           """
           |> String.trim_trailing() == serialize(byte_range)
  end
end
