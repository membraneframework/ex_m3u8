defmodule ExM3U8.Tags.StreamTest do
  use ExUnit.Case

  import ExM3U8.TestUtils, only: [serialize: 1]

  test "serialize stream" do
    stream = %ExM3U8.Tags.Stream{
      bandwidth: 6_000_000,
      average_bandwidth: 5_500_000,
      codecs: "mp4.0HEHEHE",
      resolution: {1920, 1080},
      frame_rate: 60.0,
      audio: "AUDIO",
      video: "VIDEO",
      subtitles: nil,
      uri: "http://coolstorybruh.com"
    }

    expected =
      """
      #EXT-X-STREAM-INF:BANDWIDTH=6000000,AVERAGE-BANDWIDTH=5500000,CODECS="mp4.0HEHEHE",RESOLUTION=1920x1080,FRAMERATE=60.0,AUDIO="AUDIO",VIDEO="VIDEO"
      http://coolstorybruh.com
      """
      |> String.trim_trailing()

    assert expected == serialize(stream)
  end

  test "deserialize stream" do
    attributes =
      ~s(BANDWIDTH=6000000,AVERAGE-BANDWIDTH=5500000,CODECS="mp4.0HEHEHE",RESOLUTION=1920x1080,FRAMERATE=60.0,AUDIO="AUDIO",VIDEO="VIDEO")

    assert {:ok, attrs} = ExM3U8.Deserializer.AttributesList.parse(attributes)

    stream = %ExM3U8.Tags.Stream{
      bandwidth: 6_000_000,
      average_bandwidth: 5_500_000,
      codecs: "mp4.0HEHEHE",
      resolution: {1920, 1080},
      frame_rate: 60.0,
      audio: "AUDIO",
      video: "VIDEO",
      subtitles: nil,
      uri: nil
    }

    assert {:ok, ^stream} = ExM3U8.Tags.Stream.deserialize(attrs)
  end
end
