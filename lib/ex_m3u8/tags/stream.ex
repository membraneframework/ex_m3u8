defmodule ExM3U8.Tags.Stream do
  @moduledoc """
  Structure representing a single media stream information.

  Tag is present only in multivariant playlists.
  """
  @behaviour ExM3U8.Deserializer.AttributesDeserializer

  use TypedStruct

  use ExM3U8.DSL, disable_loaders: [:boolean]

  alias ExM3U8.Deserializer.AttributesDeserializer

  typedstruct enforce: true do
    field :bandwidth, non_neg_integer()
    field :name, String.t() | nil, default: nil
    field :average_bandwidth, non_neg_integer() | nil, default: nil
    field :codecs, String.t() | nil
    field :resolution, {width :: pos_integer(), height :: pos_integer()} | nil, default: nil
    field :frame_rate, float() | nil, default: nil
    field :audio, String.t() | nil, default: nil
    field :video, String.t() | nil, default: nil
    field :subtitles, String.t() | nil, default: nil
    field :uri, String.t() | nil, default: nil
    field :pathway_id, String.t() | nil, default: nil
  end

  @impl true
  def deserialize(attrs) do
    AttributesDeserializer.deserialize_struct_fields(
      __MODULE__,
      &load/2,
      attrs
    )
  end

  load_attribute :bandwidth,
    attribute: "BANDWIDTH",
    allow_empty?: true,
    type: :int

  load_attribute :name,
    attribute: "NAME",
    allow_empty?: true

  load_attribute :average_bandwidth,
    attribute: "AVERAGE-BANDWIDTH",
    allow_empty?: true,
    type: :int

  load_attribute :codecs,
    attribute: "CODECS",
    allow_empty?: true

  load_attribute :frame_rate,
    attribute: "FRAME-RATE",
    allow_empty?: true,
    type: :float

  load_attribute :audio,
    attribute: "AUDIO",
    allow_empty?: true

  load_attribute :video,
    attribute: "VIDEO",
    allow_empty?: true

  load_attribute :subtitles,
    attribute: "SUBTITLES",
    allow_empty?: true

  load_attribute :pathway_id,
    attribute: "PATHWAY-ID",
    allow_empty?: true

  # NOTE: uri is a part of tag's new line, we don't load it from attributes
  defp load(:uri, _attrs), do: {:ok, nil}

  defp load(:resolution, attrs) do
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
        :name,
        :bandwidth,
        :average_bandwidth,
        :codecs,
        :resolution,
        :frame_rate,
        :audio,
        :video,
        :subtitles,
        :pathway_id,
        :uri
      ])
    end

    dump_attribute :bandwidth,
      attribute: "BANDWIDTH",
      skip_empty?: false

    dump_attribute :average_bandwidth,
      attribute: "AVERAGE-BANDWIDTH"

    dump_attribute :name,
      attribute: "NAME",
      quoted_string?: true

    dump_attribute :codecs,
      attribute: "CODECS",
      quoted_string?: true

    dump_attribute :frame_rate,
      attribute: "FRAME-RATE"

    dump_attribute :audio,
      attribute: "AUDIO",
      quoted_string?: true

    dump_attribute :video,
      attribute: "VIDEO",
      quoted_string?: true

    dump_attribute :subtitles,
      attribute: "SUBTITLES",
      quoted_string?: true

    dump_attribute :pathway_id,
      attribute: "PATHWAY-ID",
      quoted_string?: true

    ignore_dump(:uri)

    # resolution by hand as the value is not that easy 
    # to process
    defp dump({:resolution, nil}), do: []

    defp dump({:resolution, {width, height}}),
      do: ["RESOLUTION=", "#{width}x#{height}"]
  end
end
