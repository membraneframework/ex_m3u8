defmodule ExM3U8.Tags.MediaInit do
  @moduledoc """
  Structre represening media initialization section of for media segments.
  """
  @behaviour ExM3U8.Deserializer.AttributesDeserializer

  use TypedStruct

  typedstruct enforce: true do
    field :uri, String.t()
  end

  @impl true
  def deserialize(attrs) do
    case Map.fetch(attrs, "URI") do
      {:ok, uri} -> {:ok, %__MODULE__{uri: uri}}
      :error -> {:error, "invalid uri"}
    end
  end

  defimpl ExM3U8.Serializer do
    use ExM3U8.DSL
    require ExM3U8.Helpers

    alias ExM3U8.Helpers

    @impl true
    def serialize(%@for{uri: uri}) do
      [Helpers.tag_prefix(), "MAP:URI=", Helpers.quoted_string(uri)]
    end

    dump_attribute :uri,
      attribute: "URI",
      quoted_string?: true,
      skip_empty?: false
  end
end
