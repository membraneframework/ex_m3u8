defmodule ExM3U8.MediaPlaylistTest do
  use ExUnit.Case

  import ExM3U8.TestUtils, only: [serialize: 1]

  test "serialize info" do
    info = %ExM3U8.MediaPlaylist.Info{
      playlist_type: :vod,
      target_duration: 6,
      independent_segments: true,
      version: 7,
      server_control: %ExM3U8.MediaPlaylist.ServerControl{
        can_block_reload?: true,
        part_hold_back: 3.0,
        hold_back: 6.0,
        can_skip_until: 12.0
      },
      part_inf: 1.0,
      media_sequence: 10,
      discontinuity_sequence: 3
    }

    assert """
           #EXT-X-VERSION:7
           #EXT-X-PLAYLIST-TYPE:VOD
           #EXT-X-INDEPENDENT-SEGMENTS
           #EXT-X-TARGETDURATION:6
           #EXT-X-SERVER-CONTROL:CAN-BLOCK-RELOAD=YES,PART-HOLD-BACK=3.0,HOLD-BACK=6.0,CAN-SKIP-UNTIL=12.0
           #EXT-X-PART-INF:PART-TARGET=1.0
           #EXT-X-MEDIA-SEQUENCE:10
           #EXT-X-DISCONTINUITY-SEQUENCE:3
           """
           |> String.trim_trailing() == serialize(info)
  end

  test "serialize media playlist" do
    info = %ExM3U8.MediaPlaylist.Info{
      target_duration: 6,
      version: 7,
      server_control: %ExM3U8.MediaPlaylist.ServerControl{
        can_block_reload?: true,
        part_hold_back: 3.0,
        hold_back: 6.0,
        can_skip_until: 12.0
      },
      start: {10.0, true},
      part_inf: 1.0,
      media_sequence: 10,
      discontinuity_sequence: 3
    }

    date = ~U[2077-12-12 12:00:00Z]

    timeline =
      for i <- 1..2 do
        [
          %ExM3U8.Tags.ProgramDateTime{date: date},
          %ExM3U8.Tags.Part{duration: 1.0, uri: "segment#{i}.1.m4s"},
          %ExM3U8.Tags.Part{duration: 1.0, uri: "segment#{i}.2.m4s"},
          %ExM3U8.Tags.Part{duration: 1.0, uri: "segment#{i}.2.m4s"},
          %ExM3U8.Tags.Segment{duration: 3.0, uri: "segment#{i}.m4s"}
        ]
      end
      |> List.flatten()

    timeline =
      [
        %ExM3U8.Tags.Discontinuity{},
        %ExM3U8.Tags.MediaInit{uri: "header.mp4"}
        | timeline
      ] ++
        [
          %ExM3U8.Tags.PreloadHint{type: :part, uri: "segment3.1.m4s"},
          %ExM3U8.Tags.RenditionReport{uri: "rendition_uri.m3u8", last_msn: 5, last_part: 3}
        ]

    playlist = %ExM3U8.MediaPlaylist{
      info: info,
      timeline: [%ExM3U8.Tags.Skip{skipped_segments: 0} | timeline]
    }

    assert """
           #EXTM3U
           #EXT-X-VERSION:7
           #EXT-X-TARGETDURATION:6
           #EXT-X-SERVER-CONTROL:CAN-BLOCK-RELOAD=YES,PART-HOLD-BACK=3.0,HOLD-BACK=6.0,CAN-SKIP-UNTIL=12.0
           #EXT-X-PART-INF:PART-TARGET=1.0
           #EXT-X-MEDIA-SEQUENCE:10
           #EXT-X-DISCONTINUITY-SEQUENCE:3
           #EXT-X-START:TIME-OFFSET=10.0,PRECISE=YES
           #EXT-X-SKIP:SKIPPED-SEGMENTS=0
           #EXT-X-DISCONTINUITY
           #EXT-X-MAP:URI="header.mp4"
           #EXT-X-PROGRAM-DATE-TIME:2077-12-12T12:00:00Z
           #EXT-X-PART:DURATION=1.0,URI="segment1.1.m4s"
           #EXT-X-PART:DURATION=1.0,URI="segment1.2.m4s"
           #EXT-X-PART:DURATION=1.0,URI="segment1.2.m4s"
           #EXTINF:3.0,
           segment1.m4s
           #EXT-X-PROGRAM-DATE-TIME:2077-12-12T12:00:00Z
           #EXT-X-PART:DURATION=1.0,URI="segment2.1.m4s"
           #EXT-X-PART:DURATION=1.0,URI="segment2.2.m4s"
           #EXT-X-PART:DURATION=1.0,URI="segment2.2.m4s"
           #EXTINF:3.0,
           segment2.m4s
           #EXT-X-PRELOAD-HINT:TYPE=PART,URI="segment3.1.m4s"
           #EXT-X-RENDITION-REPORT:URI="rendition_uri.m3u8",LAST-MSN=5,LAST-PART=3
           """ == serialize(playlist)

    playlist = %ExM3U8.MediaPlaylist{
      playlist
      | info: %ExM3U8.MediaPlaylist.Info{info | end_list?: true}
    }

    assert String.ends_with?(serialize(playlist), "#EXT-X-ENDLIST\n")
  end

  test "serialize server control" do
    server_control = %ExM3U8.MediaPlaylist.ServerControl{
      can_block_reload?: true,
      part_hold_back: 3.0,
      hold_back: 6.0,
      can_skip_until: 12.0
    }

    assert """
           #EXT-X-SERVER-CONTROL:CAN-BLOCK-RELOAD=YES,PART-HOLD-BACK=3.0,HOLD-BACK=6.0,CAN-SKIP-UNTIL=12.0
           """
           |> String.trim_trailing() == serialize(server_control)
  end

  test "deserialize server control" do
    server_control = %ExM3U8.MediaPlaylist.ServerControl{
      can_block_reload?: true,
      part_hold_back: 3.0,
      hold_back: 6.0,
      can_skip_until: 12.0
    }

    {:ok, attrs} =
      ExM3U8.Deserializer.AttributesList.parse(
        "CAN-BLOCK-RELOAD=YES,PART-HOLD-BACK=3.0,HOLD-BACK=6.0,CAN-SKIP-UNTIL=12.0"
      )

    assert {:ok, server_control} ==
             ExM3U8.MediaPlaylist.ServerControl.deserialize(attrs)
  end

  test "deserialize media playlist" do
    manifest = """
    #EXTM3U
    #EXT-X-VERSION:7
    #EXT-X-INDEPENDENT-SEGMENTS
    #EXT-X-TARGETDURATION:6
    #EXT-X-SERVER-CONTROL:CAN-BLOCK-RELOAD=YES,PART-HOLD-BACK=3.0,HOLD-BACK=6.0,CAN-SKIP-UNTIL=12.0
    #EXT-X-PART-INF:PART-TARGET=1.0
    #EXT-X-MEDIA-SEQUENCE:10
    #EXT-X-DISCONTINUITY-SEQUENCE:3
    #EXT-X-START:TIME-OFFSET=10.0,PRECISE=YES
    #EXT-X-DISCONTINUITY
    #EXT-X-KEY:METHOD=AES-128,URI="key_uri.key"
    #EXT-X-MAP:URI="header.mp4"
    #EXT-X-PROGRAM-DATE-TIME:2077-12-12T12:00:00Z
    #EXT-X-PART:DURATION=1.0,URI="segment1.1.m4s"
    #EXT-X-PART:DURATION=1.0,URI="segment1.2.m4s"
    #EXT-X-PART:DURATION=1.0,URI="segment1.2.m4s"
    #EXTINF:3.0,
    segment1.m4s
    #EXT-X-PROGRAM-DATE-TIME:2077-12-12T12:00:00Z
    #EXT-X-PART:DURATION=1.0,URI="segment2.1.m4s"
    #EXT-X-PART:DURATION=1.0,URI="segment2.2.m4s"
    #EXT-X-PART:DURATION=1.0,URI="segment2.2.m4s"
    #EXTINF:3.0,
    segment2.m4s
    #EXT-X-PRELOAD-HINT:TYPE=PART,URI="segment3.1.m4s"
    #EXT-X-RENDITION-REPORT:URI="rendition_uri.m3u8",LAST-MSN=5,LAST-PART=3
    #EXT-X-ENDLIST
    """

    info = %ExM3U8.MediaPlaylist.Info{
      target_duration: 6,
      version: 7,
      independent_segments: true,
      server_control: %ExM3U8.MediaPlaylist.ServerControl{
        can_block_reload?: true,
        part_hold_back: 3.0,
        hold_back: 6.0,
        can_skip_until: 12.0
      },
      start: {10.0, true},
      part_inf: 1.0,
      media_sequence: 10,
      discontinuity_sequence: 3,
      end_list?: true
    }

    date = ~U[2077-12-12 12:00:00Z]

    timeline =
      for i <- 1..2 do
        [
          %ExM3U8.Tags.ProgramDateTime{date: date},
          %ExM3U8.Tags.Part{duration: 1.0, uri: "segment#{i}.1.m4s"},
          %ExM3U8.Tags.Part{duration: 1.0, uri: "segment#{i}.2.m4s"},
          %ExM3U8.Tags.Part{duration: 1.0, uri: "segment#{i}.2.m4s"},
          %ExM3U8.Tags.Segment{duration: 3.0, uri: "segment#{i}.m4s"}
        ]
      end
      |> List.flatten()

    timeline =
      [
        %ExM3U8.Tags.Discontinuity{},
        %ExM3U8.Tags.Key{method: :aes_128, uri: "key_uri.key"},
        %ExM3U8.Tags.MediaInit{uri: "header.mp4"}
        | timeline
      ] ++
        [
          %ExM3U8.Tags.PreloadHint{type: :part, uri: "segment3.1.m4s"},
          %ExM3U8.Tags.RenditionReport{uri: "rendition_uri.m3u8", last_msn: 5, last_part: 3}
        ]

    playlist = %ExM3U8.MediaPlaylist{
      info: info,
      timeline: timeline
    }

    assert {:ok, playlist} == ExM3U8.Deserializer.Parser.parse_media_playlist(manifest)
  end

  test "deserialize segments with nested tags" do
    manifest = """
    #EXTM3U
    #EXT-X-VERSION:7
    #EXT-X-TARGETDURATION:6
    #EXT-X-PART-INF:PART-TARGET=1.0
    #EXTINF:3.0,
    #EXT-X-BYTERANGE:426056@349786
    #EXT-X-DISCONTINUITY
    #EXT-X-PROGRAM-DATE-TIME:2077-12-12T12:00:00Z
    segment1.m4s
    """

    timeline = [
      %ExM3U8.Tags.ByteRange{offset: 349_786, length: 426_056},
      %ExM3U8.Tags.Discontinuity{},
      %ExM3U8.Tags.ProgramDateTime{date: ~U[2077-12-12 12:00:00Z]},
      %ExM3U8.Tags.Segment{uri: "segment1.m4s", duration: 3.0}
    ]

    assert {:ok, playlist} = ExM3U8.Deserializer.Parser.parse_media_playlist(manifest)
    assert playlist.timeline == timeline
  end

  defmodule CustomTag do
    @moduledoc false

    defstruct [:value]

    defimpl ExM3U8.Serializer do
      @impl true
      def serialize(%@for{value: value}) do
        ["#EXT-X-CUSTOM-KNOWN-TAG:VALUE=#{value}"]
      end
    end
  end

  test "serialize and deserialize playlist with custom tags" do
    manifest = """
    #EXTM3U
    #EXT-X-VERSION:7
    #EXT-X-TARGETDURATION:6
    #EXT-X-MEDIA-SEQUENCE:10
    #EXT-X-MAP:URI="header.mp4"
    #EXT-X-CUSTOM-UNKNOWN-TAG:VALUE=1
    #EXT-X-CUSTOM-KNOWN-TAG:VALUE=1
    """

    custom_tag_parser = fn line, lines ->
      case line do
        "#EXT-X-CUSTOM-KNOWN-TAG:VALUE=" <> value ->
          {:ok, %CustomTag{value: String.to_integer(value)}, lines}

        _other ->
          :skip
      end
    end

    assert {:ok, playlist} =
             ExM3U8.Deserializer.Parser.parse_media_playlist(manifest,
               custom_tag_parser: custom_tag_parser
             )

    assert Enum.find(playlist.timeline, fn %module{} -> module == CustomTag end)

    expected_manifest = """
    #EXTM3U
    #EXT-X-VERSION:7
    #EXT-X-TARGETDURATION:6
    #EXT-X-MEDIA-SEQUENCE:10
    #EXT-X-MAP:URI="header.mp4"
    #EXT-X-CUSTOM-KNOWN-TAG:VALUE=1
    """

    assert expected_manifest == serialize(playlist)
  end
end
