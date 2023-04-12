defmodule ExM3U8.DeserializerTest do
  use ExUnit.Case

  alias ExM3U8.Deserializer.AttributesList

  test "parse list of attributes" do
    attributes = ~s(KEYONE=value,KEYTWO=15.0,KEY-THREE="quoted_value")

    assert {:ok,
            %{
              "KEYONE" => "value",
              "KEYTWO" => "15.0",
              "KEY-THREE" => "quoted_value"
            }} = AttributesList.parse(attributes)

    assert {:ok, %{"BYTERANGE" => "10@0"}} = AttributesList.parse(~s(BYTERANGE="10@0"))

    date = "2077-12-12T12:00:00Z"
    assert {:ok, %{"DATE" => ^date}} = AttributesList.parse(~s(DATE="#{date}"))

    uri = "http://iamhappy.com/depression?attribue=something&anything"
    assert {:ok, %{"URI" => ^uri}} = AttributesList.parse(~s(URI="#{uri}"))

    assert :error = AttributesList.parse(~s(KEY:VALUE))
    assert :error = AttributesList.parse(~s(KEY1=VALUE))
  end
end
