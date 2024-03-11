# ExM3U8
[![Hex.pm](https://img.shields.io/hexpm/v/ex_m3u8.svg)](https://hex.pm/packages/ex_m3u8)
[![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](https://hexdocs.pm/ex_m3u8/)
[![CircleCI](https://circleci.com/gh/membraneframework/ex_m3u8.svg?style=svg)](https://circleci.com/gh/membraneframework/ex_m3u8)

A library for deserializing and serializing M3U8 format (known from HLS).

## Install

The package can be installed by adding `ex_m3u8` into your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_m3u8, "~> 0.13.0"}
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

## Copyright and License

Copyright 2024, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane)

Licensed under the [Apache License, Version 2.0](LICENSE)
