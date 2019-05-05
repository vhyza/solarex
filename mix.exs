defmodule Solarex.MixProject do
  use Mix.Project

  def project do
    [
      description:
        "Elixir package for calculating moon phase, sunrise and sunset for particular date and place on the Earth.",
      app: :solarex,
      source_url: "https://github.com/vhyza/solarex",
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      docs: [
        main: "Solarex",
        extras: ["README.md"]
      ],
      deps: deps(),
      package: package()
    ]
  end

  defp package() do
    [
      licenses: ["MIT"],
      maintainers: ["Vojtech Hyza"],
      links: %{"GitHub" => "https://github.com/vhyza/solarex"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      env: [known_new_moon: "2019-01-06"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:timex, "~> 3.0"},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end
end
