defmodule ExM3U8.MediaPlaylist.ServerControl do
  @moduledoc """
  Structure representing server's control information of media playlist.
  """
  @behaviour ExM3U8.Deserializer.AttributesDeserializer

  use ExM3U8.DSL, disable_loaders: [:int, :string]
  use TypedStruct

  alias ExM3U8.Deserializer.AttributesDeserializer

  typedstruct enforce: true do
    field :can_block_reload?, boolean(), default: false
    field :part_hold_back, float() | nil
    field :hold_back, float() | nil
    field :can_skip_until, float() | nil, default: nil
  end

  @impl true
  def deserialize(attrs) do
    AttributesDeserializer.deserialize_struct_fields(
      __MODULE__,
      &load/2,
      attrs
    )
  end

  load_attribute :can_block_reload?,
    attribute: "CAN-BLOCK-RELOAD",
    type: :boolean,
    allow_empty?: true

  load_attribute :part_hold_back,
    attribute: "PART-HOLD-BACK",
    type: :float,
    allow_empty?: true

  load_attribute :hold_back,
    attribute: "HOLD-BACK",
    type: :float,
    allow_empty?: true

  load_attribute :can_skip_until,
    attribute: "CAN-SKIP-UNTIL",
    type: :float,
    allow_empty?: true

  defimpl ExM3U8.Serializer do
    use ExM3U8.DSL

    require ExM3U8.Helpers

    alias ExM3U8.Helpers

    @impl true
    def serialize(%@for{} = data) do
      [
        Helpers.tag_prefix(),
        "SERVER-CONTROL:",
        Helpers.merge_attributes(data, &dump/1, &sorter/1)
      ]
    end

    defp sorter(field) do
      Helpers.generate_sorter(field, [
        :can_block_reload?,
        :part_hold_back,
        :hold_back,
        :can_skip_until
      ])
    end

    dump_attribute :can_block_reload?,
      attribute: "CAN-BLOCK-RELOAD",
      empty_arg: false,
      value: "YES"

    dump_attribute :can_skip_until,
      attribute: "CAN-SKIP-UNTIL"

    dump_attribute :part_hold_back,
      attribute: "PART-HOLD-BACK"

    dump_attribute :hold_back,
      attribute: "HOLD-BACK"
  end
end
