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
  end

  test "deserialize media init" do
    attributes = ~s(URI="header.mp4")
    {:ok, attrs} = ExM3U8.Deserializer.AttributesList.parse(attributes)

    header = %ExM3U8.Tags.MediaInit{
      uri: "header.mp4"
    }

    assert {:ok, ^header} = ExM3U8.Tags.MediaInit.deserialize(attrs)
    assert {:error, "invalid uri"} = ExM3U8.Tags.MediaInit.deserialize(%{})
  end
end
