defmodule ExM3U8.Tags.SegmentTest do
  use ExUnit.Case

  import ExM3U8.TestUtils, only: [serialize: 1]

  test "serialize segment" do
    segment = %ExM3U8.Tags.Segment{
      duration: 6.555,
      uri: "segment.m4s"
    }

    assert """
           #EXTINF:6.555,
           segment.m4s
           """
           |> String.trim_trailing() == serialize(segment)
  end
end
