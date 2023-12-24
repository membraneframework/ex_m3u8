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

  A custom parser is called on each line that a built-in parser couldn't handle. As an input it receives
  the current line and the remaining lines of the original string. As a result it should either skip
  the current lilne, return a tag and new list of remaining lines (handling a targ could take several lines) or 
  return an error.

  Note that the custom parser will be only used for tags/lines that haven't been handled by the
  built-in parser so it can't override the default handling of supported tags.
  """
  @type custom_tag_parser_t ::
          (line :: String.t(), lines :: [String.t()] -> custom_tag_parser_reusult_t())

  @type deserialize_opt_t :: {:custom_tag_parser, custom_tag_parser_t()}

  @doc """
  Serializes given playlist into a string.
  """
  @spec serialize(MediaPlaylist.t() | MultivariantPlaylist.t()) :: String.t()
  def serialize(playlist) do
    playlist
    |> __MODULE__.Serializer.serialize()
    |> IO.iodata_to_binary()
  end

  @doc """
  Deserializes given playlist string into a media playlist structure.  
  """
  @spec deserialize_media_playlist(String.t(), [deserialize_opt_t()]) ::
          {:ok, MediaPlaylist.t()} | {:error, term()}
  def deserialize_media_playlist(playlist, opts \\ []) do
    __MODULE__.Deserializer.Parser.parse_media_playlist(playlist, opts)
  end

  @doc """
  Sames as `deserialize_media_playlist/2` but raises on error.
  """
  @spec deserialize_media_playlist!(String.t(), [deserialize_opt_t()]) ::
          MediaPlaylist.t()
  def deserialize_media_playlist!(playlist, opts) do
    case deserialize_media_playlist(playlist, opts) do
      {:ok, playlist} -> playlist
      {:error, reason} -> raise reason
    end
  end

  @doc """
  Deserialies given playlist string into a multivariant playlist structure.
  """
  @spec deserialize_multivariant_playlist(String.t(), [deserialize_opt_t()]) ::
          {:ok, MultivariantPlaylist.t()} | {:error, term()}
  def deserialize_multivariant_playlist(playlist, opts \\ []) do
    __MODULE__.Deserializer.Parser.parse_multivariant_playlist(playlist, opts)
  end

  @spec deserialize_multivariant_playlist!(String.t(), [deserialize_opt_t()]) ::
          MultivariantPlaylist.t()
  def deserialize_multivariant_playlist!(playlist, opts \\ []) do
    case deserialize_multivariant_playlist(playlist, opts) do
      {:ok, playlist} -> playlist
      {:error, reason} -> raise reason
    end
  end

  @doc """
  Tries to deserialize playlist string into either a multivariant playlist or a media playlist.

  Note that this function first tries to deserialize a multivariant playlist and if it failes
  it tries to deserialize a media playlist so any errors from multivariant playlist parsing will be
  ignored and the eventual error will come from media playlist parsing.
  """
  @spec deserialize_playlist(String.t(), [deserialize_opt_t()]) ::
          {:ok, MultivariantPlaylist.t() | MediaPlaylist.t()} | {:error, term()}
  def deserialize_playlist(playlist, opts) do
    case deserialize_multivariant_playlist(playlist, opts) do
      {:ok, playlist} ->
        {:ok, playlist}

      {:error, _reason} ->
        deserialize_media_playlist(playlist, opts)
    end
  end

  @doc """
  Same as `deserialize_playlist/2` but raises on error.
  """
  @spec deserialize_playlist!(String.t(), [deserialize_opt_t()]) ::
          MultivariantPlaylist.t() | MediaPlaylist.t()
  def deserialize_playlist!(playlist, opts) do
    case deserialize_multivariant_playlist(playlist, opts) do
      {:ok, playlist} ->
        playlist

      {:error, _reason} ->
        deserialize_media_playlist!(playlist, opts)
    end
  end
end
