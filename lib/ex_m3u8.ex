defmodule ExM3U8 do
  @moduledoc """
  `ExM3U8` is a library for parsing and serializing M3U8 playlists.
  """

  alias __MODULE__.{MediaPlaylist, MultivariantPlaylist}

  @type custom_tag_parser_reusult_t ::
          :skip | {:ok, tag :: struct(), lines :: [String.t()]} | {:error, reason :: term()}

  @typedoc """
  Signature of a custom tag parser function.

  Note that the custom parser will be only used for tags/lines that haven't been handled by the
  built-in parser.
  """
  @type custom_tag_parser_t ::
          (line :: String.t(), lines :: [String.t()] -> custom_tag_parser_reusult_t())

  @type deserialize_opt_t :: {:custom_tag_parser, custom_tag_parser_t()}

  @spec serialize(MediaPlaylist.t() | MultivariantPlaylist.t()) :: String.t()
  def serialize(playlist) do
    __MODULE__.Serializer.serialize(playlist)
  end

  @spec deserialize_media_playlist(String.t(), [deserialize_opt_t()]) ::
          {:ok, MediaPlaylist.t()} | {:error, term()}
  def deserialize_media_playlist(playlist, opts \\ []) do
    __MODULE__.Deserializer.Parser.parse_media_playlist(playlist, opts)
  end

  @spec deserialize_multivariant_playlist(String.t(), [deserialize_opt_t()]) ::
          {:ok, MultivariantPlaylist.t()} | {:error, term()}
  def deserialize_multivariant_playlist(playlist, opts \\ []) do
    __MODULE__.Deserializer.Parser.parse_multivariant_playlist(playlist, opts)
  end
end
