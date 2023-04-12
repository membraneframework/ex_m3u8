defmodule ExM3U8.Deserializer.AttributesDeserializer do
  @moduledoc false

  @callback deserialize(map()) :: {:ok, struct()} | {:error, term()}

  @spec deserialize_struct_fields(module(), function(), map()) ::
          {:ok, struct()} | {:error, term()}
  def deserialize_struct_fields(module, load_fun, attrs) do
    module.__struct__
    |> Map.keys()
    # struct's fields are sorted and `__struct__` will always be first (as long
    # as the number of fields is under 32 fields).
    |> Enum.drop(1)
    |> Enum.reduce_while([], fn field, loaded ->
      case load_fun.(field, attrs) do
        {:ok, value} -> {:cont, [{field, value} | loaded]}
        {:error, _reason} = error -> {:halt, error}
      end
    end)
    |> case do
      {:error, _reason} = error ->
        error

      values ->
        {:ok, struct!(module, values)}
    end
  end
end
