defmodule ExM3U8.MediaPlaylist.Info do
  @moduledoc """
  Structure representing media's playlist information.
  """
  use TypedStruct

  typedstruct enforce: true do
    field :version, pos_integer() | nil
    field :playlist_type, :vod | :event | nil, default: nil
    field :target_duration, pos_integer()
    field :server_control, ExM3U8.MediaPlaylist.ServerControl.t() | nil, default: nil
    field :part_inf, float() | nil, default: nil
    field :media_sequence, non_neg_integer(), default: 0
    field :discontinuity_sequence, non_neg_integer(), default: 0
    # NOTE: this tag cannot be serialized along above tags
    field :end_list?, boolean(), default: false
  end

  defimpl ExM3U8.Serializer do
    use ExM3U8.DSL

    require ExM3U8.Helpers

    alias ExM3U8.Helpers

    @impl true
    def serialize(%@for{} = data) do
      Helpers.merge_tags(data, &dump/1, &sorter/1)
    end

    defp sorter(tag) do
      Helpers.generate_sorter(tag, [
        :version,
        :playlist_type,
        :target_duration,
        :server_control,
        :part_inf,
        :media_sequence,
        :discontinuity_sequence,
        :end_list?
      ])
    end

    defp dump({:playlist_type, nil}), do: []

    defp dump({:playlist_type, type}) when type in [:vod, :event] do
      type =
        case type do
          :vod -> "VOD"
          :event -> "EVENT"
        end

      [Helpers.tag_prefix(), "PLAYLIST-TYPE:", type]
    end

    dump_tag :version,
      tag: "VERSION"

    dump_tag :target_duration,
      tag: "TARGETDURATION",
      skip_empty?: false

    defp dump({:server_control, nil}), do: []

    defp dump({:server_control, server_control}), do: ExM3U8.Serializer.serialize(server_control)

    defp dump({:part_inf, nil}), do: []

    defp dump({:part_inf, part_inf}),
      do: [Helpers.tag_prefix(), "PART-INF:PART-TARGET=", "#{Float.ceil(part_inf, 5)}"]

    dump_tag :media_sequence,
      tag: "MEDIA-SEQUENCE",
      skip_empty?: false

    dump_tag :discontinuity_sequence,
      tag: "DISCONTINUITY-SEQUENCE",
      skip_empty?: true,
      empty_arg: 0

    ignore_dump(:end_list?)
  end
end
