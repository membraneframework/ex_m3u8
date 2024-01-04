# ExM3u8
A library for deserializing and serializing M3U8 format (known from HLS).

## Install

The package can be installed by adding `ex_m3u8` into your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_m3u8, "~> 0.5.0"}
  ]
end
```


## Functionality
The whole package operates on 2 types of playlists mentioned in [HLS specification](https://datatracker.ietf.org/doc/html/draft-pantos-hls-rfc8216bis).

* Multivariant playlist
* Media playlist

**Multivariant playlist** is responsible for listing available renditions (video, audio and subtitle tracks).

Each variant is represented by its own media playlist which lists media segments that
are necessary to start a proper playback.


## Usage
The library provides 4 public functions (and their '!' versions) that can be used by library's users
* `ExM3U8.serialize/1`
* `ExM3U8.deserialize_playlist/2`
* `ExM3U8.deserialize_media_playlist/2`
* `ExM3U8.deserialize_multivariant_playlist/2`


> #### Note {: .info}
>
> Due to the large number of tags in the HLS spec, the library for now only supports
> the essential ones. If a tag is missing a user may want to implement a custom tag parser
> or create a PR with a support for the new tag.

