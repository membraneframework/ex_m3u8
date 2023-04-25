defprotocol ExM3U8.Serializer do
  @moduledoc """
  Protocol for serializing playlist tags into iodata that 
  is further used for generating manifest string.
  """
  @spec serialize(struct()) :: iodata()
  def serialize(item)
end
