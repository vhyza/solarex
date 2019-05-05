# About

With Solarex Elixir package, you can calculate moon phase, sunrise and sunset for particular date and place on the Earth.

## Installation

The package can be installed by adding `solarex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:solarex, "~> 0.1.1"}
  ]
end
```

## Modules

### Moon

`Solarex.Moon` module is for calculating [moon phase](https://en.wikipedia.org/wiki/Lunar_phase#Calculating_phase) using naive approach by calculating the days from the known new moon.

You can specify known new moon using `config.exs`

```elixir
use Mix.Config

# Set the date to known new moon
#
config :solarex, known_new_moon: "2019-01-06"
```

### Sun

`Solarex.Sun` is Elixir implementation of Mike Bostock's [Solar Calculator](https://github.com/mbostock/solar-calculator). It can be used for calculating sunrise and sunset for particular date and place on earth (specified by latitude and longitude)

## Documentation

Generated documentation can be found at [Hexdocs](https://hexdocs.pm/solarex).

## License

This software is licensed under the [MIT license](LICENSE.md).
