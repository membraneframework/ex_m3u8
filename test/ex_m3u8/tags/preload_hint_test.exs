defmodule ExM3U8.Tags.PreloadHintTest do
  use ExUnit.Case

  import ExM3U8.TestUtils, only: [serialize: 1]

  test "serialize preload hint" do
    hint = %ExM3U8.Tags.PreloadHint{
      type: :part,
      uri: "part.m4s"
    }

    assert """
           #EXT-X-PRELOAD-HINT:TYPE=PART,URI="part.m4s"
           """
           |> String.trim_trailing() == serialize(hint)

    hint = %ExM3U8.Tags.PreloadHint{hint | byterange_start: 10, byterange_length: 5}

    assert """
           #EXT-X-PRELOAD-HINT:TYPE=PART,URI="part.m4s",BYTERANGE-START=10,BYTERANGE-LENGTH=5
           """
           |> String.trim_trailing() == serialize(hint)
  end

  test "deserialize preload hint" do
    attributes = ~s(TYPE=PART,URI="part.m4s")
    {:ok, attrs} = ExM3U8.Deserializer.AttributesList.parse(attributes)

    hint = %ExM3U8.Tags.PreloadHint{
      type: :part,
      uri: "part.m4s"
    }

    assert {:ok, ^hint} = ExM3U8.Tags.PreloadHint.deserialize(attrs)

    attributes = ~s(TYPE=PART,URI="part.m4s",BYTERANGE-START=10,BYTERANGE-LENGTH=5)
    {:ok, attrs} = ExM3U8.Deserializer.AttributesList.parse(attributes)

    hint = %ExM3U8.Tags.PreloadHint{
      type: :part,
      uri: "part.m4s",
      byterange_start: 10,
      byterange_length: 5
    }

    assert {:ok, ^hint} = ExM3U8.Tags.PreloadHint.deserialize(attrs)
  end
end
