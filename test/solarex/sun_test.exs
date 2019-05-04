defmodule Solarex.SunTest do
  use ExUnit.Case, async: true
  doctest Solarex.Sun

  test "should not return sunrise and sunset for places with midnight sun" do
    sunrise = Solarex.Sun.rise(~D[2017-06-14], 70.9200386, 25.3832065)
    sunset = Solarex.Sun.set(~D[2017-06-14], 70.9200386, 25.3832065)

    assert {:error, _} = sunrise
    assert {:error, _} = sunset
  end

  test "should return 24 hours of day light for places with midnight sun" do
    hours = Solarex.Sun.hours(~D[2017-06-14], 70.9200386, 25.3832065) |> Timex.Duration.to_hours()
    assert 24 == hours

    hours = Solarex.Sun.hours(~D[2016-12-14], -67.796058, 54.027812) |> Timex.Duration.to_hours()
    assert 24 == hours
  end

  test "should not return sunrise and sunset for places with polar night" do
    sunrise = Solarex.Sun.rise(~D[2016-12-14], 70.9200386, 25.3832065)
    sunset = Solarex.Sun.set(~D[2016-12-14], 70.9200386, 25.3832065)

    assert {:error, _} = sunrise
    assert {:error, _} = sunset
  end

  test "should return 0 hours of day light for places with polar night" do
    hours = Solarex.Sun.hours(~D[2016-12-14], 70.9200386, 25.3832065) |> Timex.Duration.to_hours()
    assert 0 == hours

    hours = Solarex.Sun.hours(~D[2017-06-14], -67.796058, 54.027812) |> Timex.Duration.to_hours()
    assert 0 == hours
  end
end
