defmodule ExM3U8.Tags.Media do
  @moduledoc """
  Structure representing a media tag. 
  """
  @behaviour ExM3U8.Deserializer.AttributesDeserializer

  use TypedStruct

  typedstruct enforce: true do
    field :type, :audio | :video | :subtitles | :closed_captions
    field :uri, String.t() | nil
    field :group_id, String.t()
    field :language, String.t() | nil
    field :name, String.t()
    field :default?, boolean(), default: false
    field :auto_select?, boolean(), default: false
  end

  @impl true
  def deserialize(attrs) do
    with {:ok, type} <- get_attribute(:type, attrs),
         {:ok, uri} <- get_attribute(:uri, attrs),
         {:ok, group_id} <- get_attribute(:group_id, attrs),
         {:ok, name} <- get_attribute(:name, attrs),
         {:ok, default?} <- get_attribute(:default?, attrs),
         {:ok, auto_select?} <- get_attribute(:auto_select?, attrs) do
      {:ok,
       %ExM3U8.Tags.Media{
         type: type,
         uri: uri,
         group_id: group_id,
         language: get_attribute(:language, attrs),
         name: name,
         default?: default?,
         auto_select?: auto_select?
       }}
    end
  end

  defp get_attribute(:type, attrs) do
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

  defp get_attribute(:uri, attrs) do
    with :error <- Map.fetch(attrs, "URI") do
      {:error, "uri missing"}
    end
  end

  defp get_attribute(:group_id, attrs) do
    with :error <- Map.fetch(attrs, "GROUP-ID") do
      {:error, "group id missing"}
    end
  end

  defp get_attribute(:language, attrs) do
    Map.get(attrs, "LANGUAGE")
  end

  defp get_attribute(:name, attrs) do
    with :error <- Map.fetch(attrs, "NAME") do
      {:error, "name missing"}
    end
  end

  defp get_attribute(:default?, attrs) do
    case Map.get(attrs, "DEFAULT", "NO") do
      "YES" -> {:ok, true}
      "NO" -> {:ok, false}
      _other -> {:error, "invalid default value"}
    end
  end

  defp get_attribute(:auto_select?, attrs) do
    case Map.get(attrs, "AUTOSELECT", "NO") do
      "YES" -> {:ok, true}
      "NO" -> {:ok, false}
      _other -> {:error, "invalid auto select value"}
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
        :auto_select?
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
  end
end
