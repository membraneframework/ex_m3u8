defmodule ExM3U8.MultivariantPlaylistTest do
  use ExUnit.Case

  import ExM3U8.TestUtils

  alias ExM3U8.Tags.Stream

  test "deserialize multivariant manifest" do
    manfiest = """
    #EXTM3U
    #EXT-X-VERSION:7
    #EXT-X-INDEPENDENT-SEGMENTS
    #EXT-X-STREAM-INF:BANDWIDTH=150000,RESOLUTION=416x234,CODECS="avc1.42e00a,mp4a.40.2"
    http://example.com/low/index.m3u8
    #EXT-X-STREAM-INF:BANDWIDTH=240000,RESOLUTION=416x234,CODECS="avc1.42e00a,mp4a.40.2"
    http://example.com/lo_mid/index.m3u8
    #EXT-X-STREAM-INF:BANDWIDTH=440000,RESOLUTION=416x234,CODECS="avc1.42e00a,mp4a.40.2"
    http://example.com/hi_mid/index.m3u8
    #EXT-X-STREAM-INF:BANDWIDTH=640000,RESOLUTION=640x360,CODECS="avc1.42e00a,mp4a.40.2"
    http://example.com/high/index.m3u8
    #EXT-X-STREAM-INF:BANDWIDTH=64000,CODECS="mp4a.40.5"
    http://example.com/audio/index.m3u8
    """

    assert {:ok,
            %ExM3U8.MultivariantPlaylist{
              version: 7,
              independent_segments: true,
              items: [
                %Stream{
                  bandwidth: 150_000,
                  resolution: {416, 234},
                  codecs: "avc1.42e00a,mp4a.40.2",
                  uri: "http://example.com/low/index.m3u8"
                },
                %Stream{
                  bandwidth: 240_000,
                  resolution: {416, 234},
                  codecs: "avc1.42e00a,mp4a.40.2",
                  uri: "http://example.com/lo_mid/index.m3u8"
                },
                %Stream{
                  bandwidth: 440_000,
                  resolution: {416, 234},
                  codecs: "avc1.42e00a,mp4a.40.2",
                  uri: "http://example.com/hi_mid/index.m3u8"
                },
                %Stream{
                  bandwidth: 640_000,
                  resolution: {640, 360},
                  codecs: "avc1.42e00a,mp4a.40.2",
                  uri: "http://example.com/high/index.m3u8"
                },
                %Stream{
                  bandwidth: 64_000,
                  codecs: "mp4a.40.5",
                  uri: "http://example.com/audio/index.m3u8"
                }
              ]
            }} = ExM3U8.Deserializer.Parser.parse_multivariant_playlist(manfiest)
  end

  test "serialize multivariant manifest" do
    playlist = %ExM3U8.MultivariantPlaylist{
      version: 7,
      independent_segments: true,
      items: [
        %Stream{
          subtitles: "DEFAULT",
          bandwidth: 150_000,
          resolution: {416, 234},
          codecs: "avc1.42e00a,mp4a.40.2",
          uri: "http://example.com/low/index.m3u8"
        },
        %Stream{
          video: "DEFAULT",
          bandwidth: 240_000,
          resolution: {416, 234},
          codecs: "avc1.42e00a,mp4a.40.2",
          uri: "http://example.com/lo_mid/index.m3u8"
        },
        %Stream{
          audio: "DEFAULT",
          bandwidth: 440_000,
          resolution: {416, 234},
          codecs: "avc1.42e00a,mp4a.40.2",
          uri: "http://example.com/hi_mid/index.m3u8"
        },
        %Stream{
          bandwidth: 640_000,
          resolution: {640, 360},
          frame_rate: 60.0,
          codecs: "avc1.42e00a,mp4a.40.2",
          uri: "http://example.com/high/index.m3u8"
        },
        %Stream{
          bandwidth: 64_000,
          average_bandwidth: 50_000,
          codecs: "mp4a.40.5",
          uri: "http://example.com/audio/index.m3u8"
        }
      ]
    }

    assert """
           #EXTM3U
           #EXT-X-VERSION:7
           #EXT-X-INDEPENDENT-SEGMENTS
           #EXT-X-STREAM-INF:BANDWIDTH=150000,CODECS="avc1.42e00a,mp4a.40.2",RESOLUTION=416x234,SUBTITLES="DEFAULT"
           http://example.com/low/index.m3u8
           #EXT-X-STREAM-INF:BANDWIDTH=240000,CODECS="avc1.42e00a,mp4a.40.2",RESOLUTION=416x234,VIDEO="DEFAULT"
           http://example.com/lo_mid/index.m3u8
           #EXT-X-STREAM-INF:BANDWIDTH=440000,CODECS="avc1.42e00a,mp4a.40.2",RESOLUTION=416x234,AUDIO="DEFAULT"
           http://example.com/hi_mid/index.m3u8
           #EXT-X-STREAM-INF:BANDWIDTH=640000,CODECS="avc1.42e00a,mp4a.40.2",RESOLUTION=640x360,FRAME-RATE=60.0
           http://example.com/high/index.m3u8
           #EXT-X-STREAM-INF:BANDWIDTH=64000,AVERAGE-BANDWIDTH=50000,CODECS="mp4a.40.5"
           http://example.com/audio/index.m3u8
           """ == serialize(playlist)
  end
end
