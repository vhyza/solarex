defmodule Solarex.MoonTest do
  use ExUnit.Case, async: true
  doctest Solarex.Moon

  test "should return phase for particular dates" do
    assert Solarex.Moon.phase(~D[2019-03-06]) == :new_moon
    assert Solarex.Moon.phase(~D[2019-03-08]) == :waxing_crescent
    assert Solarex.Moon.phase(~D[2019-03-14]) == :first_quarter
    assert Solarex.Moon.phase(~D[2019-03-16]) == :waxing_gibbous
    assert Solarex.Moon.phase(~D[2019-03-21]) == :full_moon
    assert Solarex.Moon.phase(~D[2019-03-23]) == :waning_gibbous
    assert Solarex.Moon.phase(~D[2019-03-28]) == :third_quarter
    assert Solarex.Moon.phase(~D[2019-03-01]) == :waning_crescent
    assert Solarex.Moon.phase(~D[2019-04-05]) == :new_moon
  end

  test "should return days elapsed from new moon phase" do
    assert Solarex.Moon.days_to_new_moon(~D[2019-02-19]) == 14
  end
end
