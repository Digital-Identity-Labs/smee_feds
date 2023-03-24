defmodule SmeeFeds.MixProject do
  use Mix.Project

  def project do
    [
      app: :smee_feds,
      version: "0.1.0",
      elixir: "~> 1.14",
      description: "A federation extension for Smee",
      package: package(),
      name: "SmeeFeds",
      source_url: "https://github.com/Digital-Identity-Labs/smee_feds",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [
        tool: ExCoveralls
      ],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      docs: [
        main: "readme",
        # logo: "path/to/logo.png",
        extras: ["README.md", "LICENSE"]
      ],
      deps: deps(),
      compilers: Mix.compilers() ++ [:rambo], # Needed until issue fixed in Rambo
      elixirc_paths: elixirc_paths(Mix.env)
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
      {:countries, "~> 1.6"},
      {:smee, ">= 0.0.0"},
      {:jason, "~> 1.4"},
      {:csv, "~> 3.0"},
      {:rambo, "~> 0.3.4"},     # temporary fix
      {:ex_json_schema, "~> 0.9.2"},
    
      {:apex, "~> 1.2", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.6.7", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.14 and >= 0.14.4", only: [:dev, :test]},
      {:benchee, "~> 1.0.1", only: [:dev, :test]},
      {:ex_doc, "~> 0.23.0", only: :dev, runtime: false},
      {:earmark, "~> 1.3", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:doctor, "~> 0.17.0", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => "https://github.com/Digital-Identity-Labs/smee_feds"
      }
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support", "priv"]
  defp elixirc_paths(_), do: ["lib", "priv"]

end
