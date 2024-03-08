defmodule ExM3U8.MixProject do
  use Mix.Project

  @version "0.13.0"
  @github_url "https://github.com/membraneframework/ex_m3u8"

  def project do
    [
      app: :ex_m3u8,
      version: @version,
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      consolidate_protocols: Mix.env() != :test,

      # hex
      description: "A package for handling M3U8 playlist files",
      package: package(),

      # docs
      name: "ExM3U8",
      source_url: @github_url,
      homepage_url: "https://membraneframework.org",
      docs: docs()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:typed_struct, "~> 0.3.0", runtime: false},
      {:nimble_parsec, "~> 1.3", runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "LICENSE"],
      formatters: ["html"],
      source_ref: "v#{@version}",
      nest_modules_by_prefix: [
        ExM3U8.Tags,
        ExM3U8.MediaPlaylist
      ],
      groups_for_modules: [
        Tags: ~r/ExM3U8\.Tags/,
        Playlists: ~r/ExM3U8\.(MediaPlaylist|MultivariantPlaylist)/
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Membrane Team"],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @github_url,
        "Membrane Framework Homepage" => "https://membraneframework.org"
      }
    ]
  end
end
