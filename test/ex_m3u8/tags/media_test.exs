defmodule ExM3U8.Tags.MediaTest do
  use ExUnit.Case

  import ExM3U8.TestUtils, only: [serialize: 1]

  test "serialize media" do
    media = %ExM3U8.Tags.Media{
      type: :audio,
      uri: "http://veryhappyme.com",
      group_id: "AUDIO",
      name: "VIDEO",
      language: "MORSE",
      default?: true,
      auto_select?: true
    }

    assert """
           #EXT-X-MEDIA:TYPE=AUDIO,URI="http://veryhappyme.com",GROUP-ID="AUDIO",LANGUAGE="MORSE",NAME="VIDEO",DEFAULT=YES,AUTOSELECT=YES
           """
           |> String.trim_trailing() == serialize(media)
  end

  test "deserialize media" do
    attributes =
      ~s(TYPE=AUDIO,URI="http://veryhappyme.com",GROUP-ID="AUDIO",LANGUAGE="MORSE",NAME="VIDEO",DEFAULT=YES,AUTOSELECT=YES)

    assert {:ok, attrs} = ExM3U8.Deserializer.AttributesList.parse(attributes)

    media = %ExM3U8.Tags.Media{
      type: :audio,
      uri: "http://veryhappyme.com",
      group_id: "AUDIO",
      name: "VIDEO",
      language: "MORSE",
      default?: true,
      auto_select?: true
    }

    assert {:ok, ^media} = ExM3U8.Tags.Media.deserialize(attrs)
  end
end
