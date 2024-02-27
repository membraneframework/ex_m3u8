defmodule ExM3U8.Tags.SkipTest do
  use ExUnit.Case

  import ExM3U8.TestUtils, only: [serialize: 1]

  test "serialize skip" do
    skip = %ExM3U8.Tags.Skip{
      skipped_segments: 10
    }

    assert """
           #EXT-X-SKIP:SKIPPED-SEGMENTS=10
           """
           |> String.trim_trailing() == serialize(skip)
  end
end
