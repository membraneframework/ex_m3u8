defmodule ExM3U8.Tags.Stream do
  @moduledoc """
  Structure representing a single media stream information.

  Tag is present only in multivariant playlists.
  """
  @behaviour ExM3U8.Deserializer.AttributesDeserializer

  use TypedStruct

  typedstruct enforce: true do
    field :bandwidth, non_neg_integer()
    field :average_bandwidth, non_neg_integer() | nil
    field :codecs, String.t() | nil
    field :resolution, {width :: pos_integer(), height :: pos_integer()} | nil
    field :frame_rate, float() | nil
    field :audio, String.t() | nil
    field :video, String.t() | nil
    field :subtitles, String.t() | nil
    field :uri, String.t() | nil, default: nil
  end

  @impl true
  def deserialize(attrs) do
    with {:ok, bandwidth} <- get_attribute(:bandwidth, attrs),
         {:ok, average_bandwidth} <- get_attribute(:average_bandwidth, attrs),
         {:ok, codecs} <- get_attribute(:codecs, attrs),
         {:ok, resolution} <- get_attribute(:resolution, attrs),
         {:ok, frame_rate} <- get_attribute(:frame_rate, attrs),
         {:ok, audio} <- get_attribute(:audio, attrs),
         {:ok, video} <- get_attribute(:video, attrs),
         {:ok, subtitles} <- get_attribute(:subtitles, attrs) do
      {:ok,
       %ExM3U8.Tags.Stream{
         bandwidth: bandwidth,
         average_bandwidth: average_bandwidth,
         codecs: codecs,
         resolution: resolution,
         frame_rate: frame_rate,
         audio: audio,
         video: video,
         subtitles: subtitles
       }}
    end
  end

  defp get_attribute(:bandwidth, attrs) do
    with {:ok, bandwidth} <- Map.fetch(attrs, "BANDWIDTH"),
         {bandwidth, ""} <- Integer.parse(bandwidth) do
      {:ok, bandwidth}
    else
      _other ->
        {:error, "invalid bandwidth"}
    end
  end

  defp get_attribute(:average_bandwidth, attrs) do
    case Map.get(attrs, "AVERAGE-BANDWIDTH", nil) do
      nil ->
        {:ok, nil}

      average_bandwidth ->
        case Integer.parse(average_bandwidth) do
          {average_bandwidth, ""} ->
            {:ok, average_bandwidth}

          :error ->
            {:error, "invalid average bandwidth"}
        end
    end
  end

  defp get_attribute(:codecs, attrs) do
    {:ok, Map.get(attrs, "CODECS")}
  end

  defp get_attribute(:resolution, attrs) do
    case Map.get(attrs, "RESOLUTION", nil) do
      nil ->
        {:ok, nil}

      resolution ->
        with [width, height] <- String.split(resolution, "x"),
             {width, ""} <- Integer.parse(width),
             {height, ""} <- Integer.parse(height) do
          {:ok, {width, height}}
        else
          _other ->
            {:error, "invalid resolution"}
        end
    end
  end

  defp get_attribute(:frame_rate, attrs) do
    case Map.get(attrs, "FRAMERATE", nil) do
      nil ->
        {:ok, nil}

      frame_rate ->
        case Float.parse(frame_rate) do
          {frame_rate, ""} -> {:ok, frame_rate}
          :error -> {:error, "invalid framerate"}
        end
    end
  end

  defp get_attribute(:audio, attrs) do
    {:ok, Map.get(attrs, "AUDIO", nil)}
  end

  defp get_attribute(:video, attrs) do
    {:ok, Map.get(attrs, "VIDEO", nil)}
  end

  defp get_attribute(:subtitles, attrs) do
    {:ok, Map.get(attrs, "SUBTITLES", nil)}
  end

  defimpl ExM3U8.Serializer do
    use ExM3U8.DSL

    require ExM3U8.Helpers

    alias ExM3U8.Helpers

    @impl true
    def serialize(%@for{uri: uri} = data) do
      [
        Helpers.tag_prefix(),
        "STREAM-INF:",
        Helpers.merge_attributes(data, &dump/1, &sorter/1),
        "\n",
        uri
      ]
    end

    defp sorter(field) do
      Helpers.generate_sorter(field, [
        :bandwidth,
        :average_bandwidth,
        :codecs,
        :resolution,
        :frame_rate,
        :audio,
        :video,
        :subtitles,
        :uri
      ])
    end

    dump_attribute :bandwidth,
      attribute: "BANDWIDTH",
      skip_empty?: false

    dump_attribute :average_bandwidth,
      attribute: "AVERAGE-BANDWIDTH"

    dump_attribute :codecs,
      attribute: "CODECS",
      quoted_string?: true

    dump_attribute :frame_rate,
      attribute: "FRAMERATE"

    dump_attribute :audio,
      attribute: "AUDIO",
      quoted_string?: true

    dump_attribute :video,
      attribute: "VIDEO",
      quoted_string?: true

    dump_attribute :subtitles,
      attribute: "SUBTITLES",
      quoted_string?: true

    ignore_dump(:uri)

    # resolution by hand as the value is not that easy 
    # to process
    defp dump({:resolution, nil}), do: []

    defp dump({:resolution, {width, height}}),
      do: ["RESOLUTION=", "#{width}x#{height}"]
  end
end
