defmodule ExM3U8.MultivariantPlaylistTest do
  use ExUnit.Case

  import ExM3U8.TestUtils

  alias ExM3U8.Tags.{ContentSteering, Media, Stream}

  test "deserialize multivariant manifest" do
    manfiest = """
    #EXTM3U
    #EXT-X-VERSION:12
    #EXT-X-INDEPENDENT-SEGMENTS
    #EXT-X-CONTENT-STEERING:SERVER-URI="http://example.com/content-steering",PATHWAY-ID="CDN-A"
    #EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="atmos-48-448",NAME="English",LANGUAGE="en-US",AUTOSELECT=YES,DEFAULT=YES,CHANNELS="16/JOC",URI="ec3-atmos-48khz-448kbps-en_audio/prog_index.m3u8"
    #EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="ac3-48-384",NAME="English",LANGUAGE="en-US",AUTOSELECT=YES,DEFAULT=YES,CHANNELS="6",URI="ac3-5.1-48khz-384kbps-en_audio/prog_index.m3u8"
    #EXT-X-STREAM-INF:BANDWIDTH=150000,RESOLUTION=416x234,CODECS="avc1.42e00a,mp4a.40.2",REQ-VIDEO-LAYOUT="CH-MONO"
    http://example.com/low/index.m3u8
    #EXT-X-STREAM-INF:BANDWIDTH=240000,RESOLUTION=416x234,CODECS="avc1.42e00a,mp4a.40.2",REQ-VIDEO-LAYOUT="CH-MONO"
    http://example.com/lo_mid/index.m3u8
    #EXT-X-STREAM-INF:BANDWIDTH=440000,RESOLUTION=416x234,CODECS="avc1.42e00a,mp4a.40.2",REQ-VIDEO-LAYOUT="CH-MONO"
    http://example.com/hi_mid/index.m3u8
    #EXT-X-STREAM-INF:BANDWIDTH=640000,RESOLUTION=640x360,CODECS="avc1.42e00a,mp4a.40.2",REQ-VIDEO-LAYOUT="CH-MONO"
    http://example.com/high/index.m3u8
    #EXT-X-STREAM-INF:BANDWIDTH=64000,CODECS="mp4a.40.5",REQ-VIDEO-LAYOUT="CH-MONO"
    http://example.com/audio/index.m3u8
    """

    assert {:ok,
            %ExM3U8.MultivariantPlaylist{
              version: 12,
              independent_segments: true,
              items: [
                %ContentSteering{
                  server_uri: "http://example.com/content-steering",
                  pathway_id: "CDN-A"
                },
                %Media{
                  type: :audio,
                  uri: "ec3-atmos-48khz-448kbps-en_audio/prog_index.m3u8",
                  group_id: "atmos-48-448",
                  language: "en-US",
                  name: "English",
                  default?: true,
                  auto_select?: true,
                  channels: "16/JOC"
                },
                %Media{
                  type: :audio,
                  uri: "ac3-5.1-48khz-384kbps-en_audio/prog_index.m3u8",
                  group_id: "ac3-48-384",
                  language: "en-US",
                  name: "English",
                  default?: true,
                  auto_select?: true,
                  channels: "6"
                },
                %Stream{
                  bandwidth: 150_000,
                  resolution: {416, 234},
                  codecs: "avc1.42e00a,mp4a.40.2",
                  uri: "http://example.com/low/index.m3u8",
                  video_layout: "CH-MONO"
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
      version: 12,
      independent_segments: true,
      items: [
        %ContentSteering{
          server_uri: "http://example.com/content-steering",
          pathway_id: "CDN-A"
        },
        %Media{
          type: :audio,
          uri: "ec3-atmos-48khz-448kbps-en_audio/prog_index.m3u8",
          group_id: "atmos-48-448",
          language: "en-US",
          name: "English",
          default?: true,
          auto_select?: true,
          channels: "16/JOC"
        },
        %Media{
          type: :audio,
          uri: "ac3-5.1-48khz-384kbps-en_audio/prog_index.m3u8",
          group_id: "ac3-48-384",
          language: "en-US",
          name: "English",
          default?: true,
          auto_select?: true,
          channels: "6"
        },
        %Stream{
          subtitles: "DEFAULT",
          bandwidth: 150_000,
          resolution: {416, 234},
          codecs: "avc1.42e00a,mp4a.40.2",
          uri: "http://example.com/low/index.m3u8",
          video_layout: "CH-MONO"
        },
        %Stream{
          video: "DEFAULT",
          bandwidth: 240_000,
          resolution: {416, 234},
          codecs: "avc1.42e00a,mp4a.40.2",
          uri: "http://example.com/lo_mid/index.m3u8",
          video_layout: "CH-MONO"
        },
        %Stream{
          audio: "DEFAULT",
          bandwidth: 440_000,
          resolution: {416, 234},
          codecs: "avc1.42e00a,mp4a.40.2",
          uri: "http://example.com/hi_mid/index.m3u8",
          video_layout: "CH-MONO"
        },
        %Stream{
          bandwidth: 640_000,
          resolution: {640, 360},
          frame_rate: 60.0,
          codecs: "avc1.42e00a,mp4a.40.2",
          uri: "http://example.com/high/index.m3u8",
          video_layout: "CH-MONO"
        },
        %Stream{
          bandwidth: 64_000,
          average_bandwidth: 50_000,
          codecs: "mp4a.40.5",
          uri: "http://example.com/audio/index.m3u8",
          video_layout: "CH-MONO"
        }
      ]
    }

    assert """
           #EXTM3U
           #EXT-X-VERSION:12
           #EXT-X-INDEPENDENT-SEGMENTS
           #EXT-X-CONTENT-STEERING:SERVER-URI="http://example.com/content-steering",PATHWAY-ID="CDN-A"
           #EXT-X-MEDIA:TYPE=AUDIO,URI="ec3-atmos-48khz-448kbps-en_audio/prog_index.m3u8",GROUP-ID="atmos-48-448",LANGUAGE="en-US",NAME="English",DEFAULT=YES,AUTOSELECT=YES,CHANNELS="16/JOC"
           #EXT-X-MEDIA:TYPE=AUDIO,URI="ac3-5.1-48khz-384kbps-en_audio/prog_index.m3u8",GROUP-ID="ac3-48-384",LANGUAGE="en-US",NAME="English",DEFAULT=YES,AUTOSELECT=YES,CHANNELS="6"
           #EXT-X-STREAM-INF:BANDWIDTH=150000,CODECS="avc1.42e00a,mp4a.40.2",RESOLUTION=416x234,SUBTITLES="DEFAULT",REQ-VIDEO-LAYOUT="CH-MONO"
           http://example.com/low/index.m3u8
           #EXT-X-STREAM-INF:BANDWIDTH=240000,CODECS="avc1.42e00a,mp4a.40.2",RESOLUTION=416x234,VIDEO="DEFAULT",REQ-VIDEO-LAYOUT="CH-MONO"
           http://example.com/lo_mid/index.m3u8
           #EXT-X-STREAM-INF:BANDWIDTH=440000,CODECS="avc1.42e00a,mp4a.40.2",RESOLUTION=416x234,AUDIO="DEFAULT",REQ-VIDEO-LAYOUT="CH-MONO"
           http://example.com/hi_mid/index.m3u8
           #EXT-X-STREAM-INF:BANDWIDTH=640000,CODECS="avc1.42e00a,mp4a.40.2",RESOLUTION=640x360,FRAME-RATE=60.0,REQ-VIDEO-LAYOUT="CH-MONO"
           http://example.com/high/index.m3u8
           #EXT-X-STREAM-INF:BANDWIDTH=64000,AVERAGE-BANDWIDTH=50000,CODECS="mp4a.40.5",REQ-VIDEO-LAYOUT="CH-MONO"
           http://example.com/audio/index.m3u8
           """ == serialize(playlist)
  end
end
