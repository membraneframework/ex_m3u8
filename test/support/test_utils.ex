defmodule ExM3U8.TestUtils do
  @moduledoc false

  @spec serialize(any()) :: String.t(0)
  def serialize(data) do
    data
    |> ExM3U8.Serializer.serialize()
    |> IO.iodata_to_binary()
  end
end
