defprotocol ExM3U8.Serializer do
  @spec serialize(struct()) :: iodata()
  def serialize(item)
end
