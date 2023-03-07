defmodule XenAPI.MixProject do
  use Mix.Project

  @source_url "https://github.com/thebinary/elixir-xenapi"
  @version "0.2.0"

  def project do
    [
      app: :xenapi,
      version: @version,
      elixir: "~> 1.14",
      name: "XenAPI",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:hackney, "~> 1.17"},
      {:xmlrpc, "~> 1.3"},
      {:httpoison, "~> 2.0"},
      {:jason, "~> 1.4"},
    ]
  end

  defp package do
    [
      description:
        "Elixir package to interact with Xen XML-RPC",
      files: ~w(lib mix.exs README.md LICENSE xenapi.json),
      maintainers: ["TheBinary"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      extras: [
        LICENSE: [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "master",
      formatters: ["html"]
    ]
  end
end
