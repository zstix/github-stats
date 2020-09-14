defmodule GithubStats.MixProject do
  use Mix.Project

  def project do
    [
      app: :github_stats,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {GithubStats.Application, []}
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.1"},
      {:neuron, "~> 5.0.0"},
      {:victor, "~> 0.1.0"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end
end
