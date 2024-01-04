defmodule ExM3U8.Tags.RenditionReportTest do
  use ExUnit.Case

  import ExM3U8.TestUtils, only: [serialize: 1]

  test "serialize rendition report" do
    report = %ExM3U8.Tags.RenditionReport{
      uri: "some_uri.m3u8",
      last_msn: 10,
      last_part: 1
    }

    assert """
           #EXT-X-RENDITION-REPORT:URI="some_uri.m3u8",LAST-MSN=10,LAST-PART=1
           """
           |> String.trim_trailing() == serialize(report)
  end

  test "deserialize rendition report" do
    attributes = ~s(URI="some_uri.m3u8",LAST-MSN=10,LAST-PART=1)

    assert {:ok, attrs} = ExM3U8.Deserializer.AttributesList.parse(attributes)

    report = %ExM3U8.Tags.RenditionReport{
      uri: "some_uri.m3u8",
      last_msn: 10,
      last_part: 1
    }

    assert {:ok, ^report} = ExM3U8.Tags.RenditionReport.deserialize(attrs)
  end
end
