defmodule ExM3U8.Deserializer.Parser do
  @moduledoc false

  import ExM3U8.Deserializer.DSL

  require ExM3U8.Deserializer.DSL

  alias ExM3U8.Deserializer.AttributesList

  @type custom_tag_parser_result ::
          :skip
          | {:ok, tag :: struct(), remaining_lines :: [String.t()]}
          | {:error, reason :: term()}

  @type custom_tag_parser ::
          (current_line :: String.t(), remaining_lines :: [String.t()] ->
             custom_tag_parser_result())

  @extm3u "#EXTM3U"

  defp is_tag({tag, _value}, tags), do: tag in tags

  @spec parse_multivariant_playlist(String.t(), keyword()) ::
          {:ok, ExM3U8.MultivariantPlaylist.t()} | {:error, term()}
  def parse_multivariant_playlist(payload, opts \\ []) do
    payload
    |> String.split("\n")
    |> do_parse([], opts)
    |> assemble_multi_variant_playlist()
  end

  defp assemble_multi_variant_playlist({:error, _reason} = error), do: error

  defp assemble_multi_variant_playlist(tags) do
    items =
      tags
      |> Enum.filter(fn {tag, _item} -> tag in [:stream, :content_steering, :media] end)
      |> Enum.map(fn {_tag, item} -> item end)

    {:version, version} =
      Enum.find(tags, {:version, nil}, fn {tag, _version} -> tag == :version end)

    {:independent_segments, independent_segments} =
      Enum.find(
        tags,
        {:independent_segments, false},
        fn {tag, _independent_segments} -> tag == :independent_segments end
      )

    {:ok,
     %ExM3U8.MultivariantPlaylist{
       version: version,
       independent_segments: independent_segments,
       items: items
     }}
  end

  @spec parse_media_playlist(String.t(), keyword()) ::
          {:ok, ExM3U8.MediaPlaylist.t()} | {:error, term()}
  def parse_media_playlist(payload, opts \\ []) do
    payload
    |> String.split("\n")
    |> do_parse([], opts)
    |> assemble_media_playlist()
  end

  defp assemble_media_playlist({:error, _reason} = error), do: error

  @info_tags [
    :version,
    :independent_segments,
    :playlist_type,
    :target_duration,
    :server_control,
    :part_inf,
    :media_sequence,
    :discontinuity_sequence,
    :start,
    :end_list
  ]
  @timeline_tags [
    :skip,
    :program_date_time,
    :byterange,
    :media_init,
    :part,
    :segment,
    :key,
    :discontinuity,
    :hint,
    :rendition_report,
    :custom_tag
  ]
  defp assemble_media_playlist(tags) do
    {info_tags, other_tags} = Enum.split_with(tags, &is_tag(&1, @info_tags))

    with {:ok, info} <- assemble_media_playlist_info(info_tags) do
      timeline =
        other_tags
        |> Enum.filter(&is_tag(&1, @timeline_tags))
        |> Enum.map(&elem(&1, 1))

      {:ok, %ExM3U8.MediaPlaylist{info: info, timeline: timeline}}
    end
  end

  defp assemble_media_playlist_info(tags) do
    case Keyword.validate(
           tags,
           [
             :target_duration,
             version: nil,
             playlist_type: nil,
             independent_segments: false,
             server_control: nil,
             part_inf: nil,
             media_sequence: 0,
             discontinuity_sequence: 0,
             start: nil,
             end_list: false
           ]
         ) do
      {:ok, tags} ->
        tags =
          tags
          |> Keyword.delete(:end_list)
          |> Keyword.put(:end_list?, tags[:end_list])

        {:ok, struct!(ExM3U8.MediaPlaylist.Info, tags)}

      {:error, fields} ->
        description = Enum.map_join(fields, ", ", &to_string/1)
        {:error, "missing required media playlist info field: #{description}"}
    end
  end

  defp do_parse(lines, acc, opts)

  defp do_parse([], acc, _opts) do
    Enum.reverse(acc)
  end

  defp do_parse([@extm3u | lines], acc, opts) do
    do_parse(lines, acc, opts)
  end

  parse_tag "PART" do
    with {:ok, attrs} <- AttributesList.parse(value),
         {:ok, part} <- ExM3U8.Tags.Part.deserialize(attrs) do
      {:ok, :part, part}
    else
      :error ->
        {:error, "invalid part tag"}

      {:error, _reason} ->
        {:error, "invalid part tag"}
    end
  end

  defp do_parse(["#EXTINF:" <> value | lines], acc, opts) do
    case Float.parse(value) do
      {duration, ","} ->
        parse_segment(duration, lines, acc, opts)

      :error ->
        {:error, "invalid segment duration"}
    end
  end

  parse_tag "PROGRAM-DATE-TIME" do
    case DateTime.from_iso8601(value) do
      {:ok, date_time, _rest} ->
        {:ok, :program_date_time, %ExM3U8.Tags.ProgramDateTime{date: date_time}}

      _other ->
        {:error, "invalid program date time"}
    end
  end

  parse_tag "BYTERANGE" do
    case String.split(value, "@") do
      [length] ->
        case Integer.parse(length) do
          {length, ""} -> {:ok, :byterange, %ExM3U8.Tags.ByteRange{length: length}}
          :error -> {:error, "invalid byterange"}
        end

      [length, offset] ->
        with {length, ""} <- Integer.parse(length),
             {offset, ""} <- Integer.parse(offset) do
          {:ok, :byterange, %ExM3U8.Tags.ByteRange{length: length, offset: offset}}
        else
          _other ->
            {:error, "invalid byterange"}
        end

      _other ->
        {:error, "invalid byterange"}
    end
  end

  parse_tag "MAP" do
    case AttributesList.parse(value) do
      {:ok, %{"URI" => uri}} ->
        {:ok, :media_init, %ExM3U8.Tags.MediaInit{uri: uri}}

      _other ->
        {:error, "invalid map tag"}
    end
  end

  parse_tag "PLAYLIST-TYPE" do
    case value do
      "VOD" -> {:ok, :playlist_type, :vod}
      "EVENT" -> {:ok, :playlist_type, :event}
      _other -> {:error, "invalid playlist type"}
    end
  end

  parse_tag "VERSION" do
    case Integer.parse(value) do
      {version, ""} -> {:ok, :version, version}
      :error -> {:error, "invalid version value"}
    end
  end

  parse_raw "#EXT-X-INDEPENDENT-SEGMENTS" do
    _value = value
    _lines = lines

    {:ok, :independent_segments, true, lines}
  end

  parse_tag "TARGETDURATION" do
    case Integer.parse(value) do
      {duration, ""} -> {:ok, :target_duration, duration}
      :error -> {:ierror, "invalid version value"}
    end
  end

  parse_tag "MEDIA-SEQUENCE" do
    case Integer.parse(value) do
      {seq, ""} -> {:ok, :media_sequence, seq}
      :error -> {:error, "invalid media sequence"}
    end
  end

  parse_tag "DISCONTINUITY-SEQUENCE" do
    case Integer.parse(value) do
      {seq, ""} -> {:ok, :discontinuity_sequence, seq}
      :error -> {:error, "invalid discontinuity sequence"}
    end
  end

  parse_tag "SERVER-CONTROL" do
    with {:ok, attrs} <- AttributesList.parse(value),
         {:ok, server_control} <- ExM3U8.MediaPlaylist.ServerControl.deserialize(attrs) do
      {:ok, :server_control, server_control}
    else
      :error ->
        {:error, "invalid server control atttributes"}

      {:error, _reason} ->
        {:error, "invalid server control atttributes"}
    end
  end

  parse_raw "#EXT-X-DISCONTINUITY" do
    _value = value
    {:ok, :discontinuity, %ExM3U8.Tags.Discontinuity{}, lines}
  end

  parse_raw "#EXT-X-PART-INF:PART-TARGET=" do
    case Float.parse(value) do
      {value, ""} -> {:ok, :part_inf, value, lines}
      :error -> {:error, "invalid part inf value"}
    end
  end

  parse_tag "START" do
    with {:ok, attrs} <- AttributesList.parse(value),
         {:ok, time_offset} <- Map.fetch(attrs, "TIME-OFFSET"),
         precise <- Map.get(attrs, "PRECISE", "NO"),
         {time_offset, ""} <- Float.parse(time_offset) do
      precise =
        case precise do
          "YES" -> true
          "NO" -> false
          _other -> false
        end

      {:ok, :start, {time_offset, precise}}
    else
      :error ->
        {:error, "invalid start tag"}

      {:error, _reason} ->
        {:error, "invalid start tag"}

      {time, _rest} when is_float(time) ->
        {:error, "invalid start tag time offset"}
    end
  end

  parse_tag "SKIP" do
    case AttributesList.parse(value) do
      {:ok, attributes} ->
        with {:ok, skip} <- ExM3U8.Tags.Skip.deserialize(attributes) do
          {:ok, :skip, skip}
        end

      :error ->
        {:error, "invalid skip tag"}
    end
  end

  parse_tag "MEDIA" do
    case AttributesList.parse(value) do
      {:ok, attributes} ->
        with {:ok, media} <- ExM3U8.Tags.Media.deserialize(attributes) do
          {:ok, :media, media}
        end

      :error ->
        {:error, "invalid media tag"}
    end
  end

  parse_tag "KEY" do
    case AttributesList.parse(value) do
      {:ok, attributes} ->
        with {:ok, key} <- ExM3U8.Tags.Key.deserialize(attributes) do
          {:ok, :key, key}
        end

      :error ->
        {:error, "invalid key tag"}
    end
  end

  parse_raw "#EXT-X-STREAM-INF:" do
    with {:ok, attrs} <- AttributesList.parse(value),
         [uri | lines] <- lines,
         {:ok, variant} <- ExM3U8.Tags.Stream.deserialize(attrs) do
      {:ok, :stream, %ExM3U8.Tags.Stream{variant | uri: uri}, lines}
    else
      _other ->
        {:error, "invalid stream inf tag"}
    end
  end

  parse_tag "CONTENT-STEERING" do
    with {:ok, attrs} <- AttributesList.parse(value),
         {:ok, steering} <- ExM3U8.Tags.ContentSteering.deserialize(attrs) do
      {:ok, :content_steering, steering}
    else
      _other ->
        {:error, "invalid content steering tag"}
    end
  end

  parse_tag "RENDITION-REPORT" do
    case AttributesList.parse(value) do
      {:ok, attributes} ->
        with {:ok, report} <- ExM3U8.Tags.RenditionReport.deserialize(attributes) do
          {:ok, :rendition_report, report}
        end

      :error ->
        {:error, "invalid rendition report tag"}
    end
  end

  parse_tag "PRELOAD-HINT" do
    case AttributesList.parse(value) do
      {:ok, attributes} ->
        with {:ok, hint} <- ExM3U8.Tags.PreloadHint.deserialize(attributes) do
          {:ok, :hint, hint}
        end

      :error ->
        {:error, "invalid rendition preload hint tag"}
    end
  end

  parse_raw "#EXT-X-ENDLIST" do
    _value = value

    {:ok, :end_list, true, lines}
  end

  defp do_parse([line | lines], acc, opts) do
    opts
    |> Keyword.get_values(:custom_tag_parser)
    |> Enum.reduce_while({lines, acc}, fn parser, {lines, acc} ->
      case parser.(line, lines) do
        {:ok, tag, lines} ->
          {:halt, {lines, [{:custom_tag, tag} | acc]}}

        :skip ->
          {:cont, {lines, acc}}

        {:error, _reason} = error ->
          {:halt, error}
      end
    end)
    |> case do
      {:error, _reason} = error -> error
      {lines, acc} -> do_parse(lines, acc, opts)
    end
  end

  defp parse_segment(duration, lines, acc, opts) do
    {segment_tags, lines} = Enum.split_while(lines, &String.starts_with?(&1, "#"))

    case do_parse(segment_tags, [], opts) do
      {:error, _reason} = error ->
        error

      segment_tags ->
        acc = Enum.reduce(segment_tags, acc, &[&1 | &2])

        case lines do
          [uri | lines] ->
            do_parse(
              lines,
              [{:segment, %ExM3U8.Tags.Segment{duration: duration, uri: uri}} | acc],
              opts
            )

          [] ->
            {:error, "missing segment uri"}
        end
    end
  end
end
