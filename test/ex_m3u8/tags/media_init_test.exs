defmodule ExM3U8.Tags.MediaInitTest do
  use ExUnit.Case

  import ExM3U8.TestUtils, only: [serialize: 1]

  test "serialize media init" do
    header = %ExM3U8.Tags.MediaInit{
      uri: "header.mp4"
    }

    assert """
           #EXT-X-MAP:URI="header.mp4"
           """
           |> String.trim_trailing() == serialize(header)

    header = %ExM3U8.Tags.MediaInit{
      uri: "header.mp4",
      byte_range: {100, 0}
    }

    assert """
           #EXT-X-MAP:URI="header.mp4",BYTERANGE="100@0"
           """
           |> String.trim_trailing() == serialize(header)

    header = %ExM3U8.Tags.MediaInit{
      uri: "header.mp4",
      byte_range: {100, nil}
    }

    assert """
           #EXT-X-MAP:URI="header.mp4",BYTERANGE="100"
           """
           |> String.trim_trailing() == serialize(header)
  end

  test "deserialize media init" do
    attributes = ~s(URI="header.mp4",BYTERANGE="100@0")
    {:ok, attrs} = ExM3U8.Deserializer.AttributesList.parse(attributes)

    header = %ExM3U8.Tags.MediaInit{
      uri: "header.mp4",
      byte_range: {100, 0}
    }

    assert {:ok, ^header} = ExM3U8.Tags.MediaInit.deserialize(attrs)

    attributes = ~s(URI="header.mp4")
    {:ok, attrs} = ExM3U8.Deserializer.AttributesList.parse(attributes)

    header = %ExM3U8.Tags.MediaInit{
      uri: "header.mp4",
      byte_range: nil
    }

    assert {:ok, ^header} = ExM3U8.Tags.MediaInit.deserialize(attrs)

    assert {:error, "missing value" <> _rest} = ExM3U8.Tags.MediaInit.deserialize(%{})
  end
end
