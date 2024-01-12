defmodule ExM3U8.Tags.ContentSteeringTest do
  use ExUnit.Case

  import ExM3U8.TestUtils, only: [serialize: 1]

  test "serialize content steering" do
    steering = %ExM3U8.Tags.ContentSteering{
      server_uri: "http://veryhappyme.com/content-steering",
      pathway_id: "CDN-A"
    }

    assert """
           #EXT-X-CONTENT-STEERING:SERVER-URI="http://veryhappyme.com/content-steering",PATHWAY-ID="CDN-A"
           """
           |> String.trim_trailing() == serialize(steering)
  end

  test "deserialize content steering" do
    attributes =
      ~s(SERVER-URI="http://veryhappyme.com/content-steering",PATHWAY-ID="CDN-A")

    assert {:ok, attrs} = ExM3U8.Deserializer.AttributesList.parse(attributes)

    steering = %ExM3U8.Tags.ContentSteering{
      server_uri: "http://veryhappyme.com/content-steering",
      pathway_id: "CDN-A"
    }

    assert {:ok, ^steering} = ExM3U8.Tags.ContentSteering.deserialize(attrs)
  end
end
