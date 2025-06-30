defmodule ExM3U8.TestUtils do
  @moduledoc false

  @spec serialize(any()) :: String.t()
  def serialize(data) do
    data
    |> ExM3U8.Serializer.serialize()
    |> IO.iodata_to_binary()
  end
end
