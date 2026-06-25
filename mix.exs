defmodule ExM3U8.MixProject do
  use Mix.Project

  @version "0.16.1"
  @github_url "https://github.com/membraneframework/ex_m3u8"

  def project do
    [
      app: :ex_m3u8,
      version: @version,
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),
      consolidate_protocols: Mix.env() != :test,

      # hex
      description: "A package for handling M3U8 playlist files",
      package: package(),

      # docs
      name: "ExM3U8",
      source_url: @github_url,
      homepage_url: "https://membraneframework.org",
      docs: docs(),
      aliases: [docs: ["docs", &prepend_llms_links/1]]
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
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev], runtime: false}
    ]
  end

  defp dialyzer() do
    opts = [
      flags: [:error_handling]
    ]

    if System.get_env("CI") == "true" do
      # Store PLTs in cacheable directory for CI
      File.mkdir_p!(Path.join([__DIR__, "priv", "plts"]))
      [plt_local_path: "priv/plts", plt_core_path: "priv/plts"] ++ opts
    else
      opts
    end
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "LICENSE"],
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

  defp prepend_llms_links(_) do
    output_dir = docs()[:output] || "doc"
    path = Path.join(output_dir, "llms.txt")

    if File.exists?(path) do
      existing = File.read!(path)

      footer = """


      ## See Also

      - [Membrane Framework AI Skill](https://hexdocs.pm/membrane_core/skill.md)
      - [Membrane Core](https://hexdocs.pm/membrane_core/llms.txt)
      """

      File.write!(path, String.trim_trailing(existing) <> footer)
    else
      IO.warn("#{path} not found — llms.txt was not generated, check your ex_doc configuration")
    end
  end
end
