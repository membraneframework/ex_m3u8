defmodule ExM3U8 do
  @moduledoc """
  # ExM3u8
  A library for deserializing and serializing M3U8 format (known from HLS).

  ## Functionality
  The whole package operates on 2 types of playlists mentioned in [HLS specification](https://datatracker.ietf.org/doc/html/draft-pantos-hls-rfc8216bis).

  * Multivariant playlist
  * Media playlist

  **Multivariant playlist** is responsible for listing available renditions (video, audio and subtitle tracks).

  Each variant is represented by its own media playlist which lists media segments that
  are necessary to start a proper playback.


  ## Usage
  The library provides 3 public functions that can be used by library's users
  * `ExM3U8.serialize/1`
  * `ExM3U8.deserialize_media_playlist/2`
  * `ExM3U8.deserialize_multivariant_playlist/2`


  > #### Note {: .info}
  >
  > Due to the large number of tags in the HLS spec, the library for now only supports
  > the essential ones. If a tag is missing a user may want to implement a custom tag parser
  > or create a PR with a support for the new tag.
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
