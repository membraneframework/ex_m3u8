defmodule ExM3U8.Tags.Media do
  @moduledoc """
  Structure representing a media tag.
  """
  @behaviour ExM3U8.Deserializer.AttributesDeserializer

  use TypedStruct
  use ExM3U8.DSL, disable_loaders: [:int, :float]

  alias ExM3U8.Deserializer.AttributesDeserializer

  typedstruct enforce: true do
    field :type, :audio | :video | :subtitles | :closed_captions
    field :uri, String.t() | nil
    field :group_id, String.t()
    field :language, String.t() | nil
    field :name, String.t()
    field :default?, boolean(), default: false
    field :auto_select?, boolean(), default: false
    field :channels, String.t() | nil, default: nil
  end

  @impl true
  def deserialize(attrs) do
    AttributesDeserializer.deserialize_struct_fields(
      __MODULE__,
      &load/2,
      attrs
    )
  end

  load_attribute :uri,
    attribute: "URI",
    allow_empty?: false

  load_attribute :group_id,
    attribute: "GROUP-ID",
    allow_empty?: false

  load_attribute :language,
    attribute: "LANGUAGE",
    allow_empty?: true

  load_attribute :name,
    attribute: "NAME",
    allow_empty?: false

  load_attribute :default?,
    attribute: "DEFAULT",
    allow_empty?: true,
    default: false,
    type: :boolean

  load_attribute :auto_select?,
    attribute: "AUTOSELECT",
    default: false,
    allow_empty?: true,
    type: :boolean

  load_attribute :channels,
    attribute: "CHANNELS",
    allow_empty?: true

  defp load(:type, attrs) do
    case Map.get(attrs, "TYPE", nil) do
      "AUDIO" -> :audio
      "VIDEO" -> :video
      "SUBTITLES" -> :subtitles
      "CLOSED-CAPTIONS" -> :closed_captions
      _other -> nil
    end
    |> case do
      nil -> {:error, "invalid media type"}
      type -> {:ok, type}
    end
  end

  defimpl ExM3U8.Serializer do
    use ExM3U8.DSL

    require ExM3U8.Helpers

    alias ExM3U8.Helpers

    @impl true
    def serialize(%@for{} = data) do
      [
        Helpers.tag_prefix(),
        "MEDIA:",
        data
        |> map_type()
        |> Helpers.merge_attributes(&dump/1, &sorter/1)
      ]
    end

    defp sorter(field) do
      Helpers.generate_sorter(field, [
        :type,
        :uri,
        :group_id,
        :language,
        :name,
        :default?,
        :auto_select?,
        :channels
      ])
    end

    defp map_type(%@for{type: type} = data) do
      type =
        case type do
          :audio -> "AUDIO"
          :video -> "VIDEO"
          :subtitles -> "SUBTITLES"
          :closed_captions -> "CLOSED-CAPTIONS"
        end

      %@for{data | type: type}
    end

    dump_attribute :type,
      attribute: "TYPE",
      skip_empty?: false

    dump_attribute :uri,
      attribute: "URI",
      quoted_string?: true

    dump_attribute :group_id,
      attribute: "GROUP-ID",
      quoted_string?: true,
      skip_empty?: false

    dump_attribute :language,
      attribute: "LANGUAGE",
      quoted_string?: true

    dump_attribute :name,
      attribute: "NAME",
      quoted_string?: true,
      skip_empty?: false

    dump_attribute :default?,
      attribute: "DEFAULT",
      empty_arg: false

    dump_attribute :auto_select?,
      attribute: "AUTOSELECT",
      empty_arg: false

    dump_attribute :channels,
      attribute: "CHANNELS",
      quoted_string?: true,
      skip_empty?: true
  end
end
