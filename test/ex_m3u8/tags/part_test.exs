defmodule ExM3U8.Tags.PartTest do
  use ExUnit.Case

  import ExM3U8.TestUtils, only: [serialize: 1]

  test "serialize part" do
    part = %ExM3U8.Tags.Part{
      duration: 1.22,
      uri: "part.m4s",
      independent?: true
    }

    assert """
           #EXT-X-PART:DURATION=1.22,URI="part.m4s",INDEPENDENT=YES
           """
           |> String.trim_trailing() == serialize(part)

    part = %ExM3U8.Tags.Part{part | independent?: false}

    assert """
           #EXT-X-PART:DURATION=1.22,URI="part.m4s"
           """
           |> String.trim_trailing() == serialize(part)

    part = %ExM3U8.Tags.Part{part | byte_range: {10, nil}}

    assert """
           #EXT-X-PART:DURATION=1.22,URI="part.m4s",BYTERANGE="10"
           """
           |> String.trim_trailing() == serialize(part)

    part = %ExM3U8.Tags.Part{part | byte_range: {10, 5}}

    assert """
           #EXT-X-PART:DURATION=1.22,URI="part.m4s",BYTERANGE="10@5"
           """
           |> String.trim_trailing() == serialize(part)
  end

  test "deserialize part" do
    attributes = ~s(DURATION=1.22,URI="part.m4s",INDEPENDENT=YES)
    {:ok, attrs} = ExM3U8.Deserializer.AttributesList.parse(attributes)

    part = %ExM3U8.Tags.Part{
      duration: 1.22,
      uri: "part.m4s",
      independent?: true
    }

    assert {:ok, ^part} = ExM3U8.Tags.Part.deserialize(attrs)

    attributes = ~s(DURATION=1.22,URI="part.m4s")
    {:ok, attrs} = ExM3U8.Deserializer.AttributesList.parse(attributes)

    part = %ExM3U8.Tags.Part{
      duration: 1.22,
      uri: "part.m4s",
      independent?: false
    }

    assert {:ok, ^part} = ExM3U8.Tags.Part.deserialize(attrs)

    attributes = ~s(DURATION=1.22,URI="part.m4s",BYTERANGE="10")
    {:ok, attrs} = ExM3U8.Deserializer.AttributesList.parse(attributes)

    part = %ExM3U8.Tags.Part{
      duration: 1.22,
      uri: "part.m4s",
      byte_range: {10, nil},
      independent?: false
    }

    assert {:ok, ^part} = ExM3U8.Tags.Part.deserialize(attrs)

    attributes = ~s(DURATION=1.22,URI="part.m4s",BYTERANGE="10@5")
    {:ok, attrs} = ExM3U8.Deserializer.AttributesList.parse(attributes)

    part = %ExM3U8.Tags.Part{
      duration: 1.22,
      uri: "part.m4s",
      byte_range: {10, 5},
      independent?: false
    }

    assert {:ok, ^part} = ExM3U8.Tags.Part.deserialize(attrs)
  end
end
