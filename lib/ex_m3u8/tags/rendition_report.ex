defmodule ExM3U8.Tags.RenditionReport do
  @moduledoc """
  Structure representing a rendition report. 
  """
  @behaviour ExM3U8.Deserializer.AttributesDeserializer

  use TypedStruct

  typedstruct enforce: true do
    field :uri, String.t()
    field :last_msn, integer()
    field :last_part, integer()
  end

  @impl true
  def deserialize(attrs) do
    with {:ok, uri} <- get_attribute(:uri, attrs),
         {:ok, last_msn} <- get_attribute(:last_msn, attrs),
         {:ok, last_part} <- get_attribute(:last_part, attrs) do
      {:ok,
       %ExM3U8.Tags.RenditionReport{
         uri: uri,
         last_msn: last_msn,
         last_part: last_part
       }}
    end
  end

  defp get_attribute(:uri, attrs) do
    with :error <- Map.fetch(attrs, "URI") do
      {:error, "uri missing"}
    end
  end

  defp get_attribute(:last_msn, attrs) do
    with {:ok, last_msn} <- Map.fetch(attrs, "LAST-MSN"),
         {last_msn, ""} <- Integer.parse(last_msn) do
      {:ok, last_msn}
    else
      _other ->
        {:error, "invalid last msn"}
    end
  end

  defp get_attribute(:last_part, attrs) do
    with {:ok, last_part} <- Map.fetch(attrs, "LAST-PART"),
         {last_part, ""} <- Integer.parse(last_part) do
      {:ok, last_part}
    else
      _other ->
        {:error, "invalid last part"}
    end
  end

  defimpl ExM3U8.Serializer do
    use ExM3U8.DSL

    require ExM3U8.Helpers

    alias ExM3U8.Helpers

    @impl true
    def serialize(%@for{} = data) do
      [
        ExM3U8.Helpers.tag_prefix(),
        "RENDITION-REPORT:",
        Helpers.merge_attributes(data, &dump/1, &sorter/1)
      ]
    end

    defp sorter(field) do
      Helpers.generate_sorter(field, [
        :uri,
        :last_msn,
        :last_part
      ])
    end

    dump_attribute :uri,
      attribute: "URI",
      skip_empty?: false,
      quoted_string?: true

    dump_attribute :last_msn,
      attribute: "LAST-MSN",
      skip_empty?: false

    dump_attribute :last_part,
      attribute: "LAST-PART",
      skip_empty?: false
  end
end
