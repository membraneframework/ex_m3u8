defmodule ExM3U8.Tags.KeyTest do
  use ExUnit.Case

  import ExM3U8.TestUtils, only: [serialize: 1]

  test "serialize key" do
    key = %ExM3U8.Tags.Key{
      method: :aes_128,
      uri: "some_uri.key"
    }

    assert """
           #EXT-X-KEY:METHOD=AES-128,URI="some_uri.key"
           """
           |> String.trim_trailing() == serialize(key)

    key = %ExM3U8.Tags.Key{key | iv: "iv"}

    assert """
           #EXT-X-KEY:METHOD=AES-128,URI="some_uri.key",IV=iv
           """
           |> String.trim_trailing() == serialize(key)

    key = %ExM3U8.Tags.Key{key | key_format: "format"}

    assert """
           #EXT-X-KEY:METHOD=AES-128,URI="some_uri.key",IV=iv,KEYFORMAT="format"
           """
           |> String.trim_trailing() == serialize(key)
  end

  test "deserialize key" do
    attributes = ~s(METHOD=AES-128,URI="some_uri.key",IV=iv)
    {:ok, attrs} = ExM3U8.Deserializer.AttributesList.parse(attributes)

    key = %ExM3U8.Tags.Key{
      method: :aes_128,
      uri: "some_uri.key",
      iv: "iv"
    }

    assert {:ok, ^key} = ExM3U8.Tags.Key.deserialize(attrs)
  end
end
