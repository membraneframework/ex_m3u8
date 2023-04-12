defmodule ExM3U8.Tags.VariantTest do
  use ExUnit.Case

  import ExM3U8.TestUtils, only: [serialize: 1]

  test "serialize variant" do
    variant = %ExM3U8.Tags.Variant{
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
           |> String.trim_trailing() == serialize(variant)
  end

  test "deserialize variant" do
    attributes =
      ~s(TYPE=AUDIO,URI="http://veryhappyme.com",GROUP-ID="AUDIO",LANGUAGE="MORSE",NAME="VIDEO",DEFAULT=YES,AUTOSELECT=YES)

    assert {:ok, attrs} = ExM3U8.Deserializer.AttributesList.parse(attributes)

    variant = %ExM3U8.Tags.Variant{
      type: :audio,
      uri: "http://veryhappyme.com",
      group_id: "AUDIO",
      name: "VIDEO",
      language: "MORSE",
      default?: true,
      auto_select?: true
    }

    assert {:ok, ^variant} = ExM3U8.Tags.Variant.deserialize(attrs)
  end
end
