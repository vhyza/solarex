defmodule Solarex.Moon do
  @moduledoc """
  Solarex.Moon is module for calculating moon phase for particular date.

  This module implements naive approach by calculating the number of days since a known new moon.
  See [Wikipedia](https://en.wikipedia.org/wiki/Lunar_phase#Calculating_phase) page for more info.
  """

  @doc """
  Returns moon phase for the current date.
  """
  @spec phase() :: atom()
  def phase() do
    Timex.today()
    |> phase()
  end

  @doc """
  Calculate moon phase for the passed Date.

  Returns one of `:new_moon`, `:waxing_crescent`, `:first_quarter`, `:waxing_gibbous`,
  `:full_moon`, `:waning_gibbous`, `:third_quarter`, `:waning_crescent`, `:new_moon` atom.

      iex> Solarex.Moon.phase(~D[2019-05-05])
      :new_moon
  """
  @spec phase(Date.t()) :: atom()
  def phase(%Date{} = date) do
    case days_to_new_moon(date) do
      d when d in 0..1 ->
        :new_moon

      d when d in 2..6 ->
        :waxing_crescent

      d when d in 7..8 ->
        :first_quarter

      d when d in 9..13 ->
        :waxing_gibbous

      d when d in 14..15 ->
        :full_moon

      d when d in 16..21 ->
        :waning_gibbous

      d when d in 22..23 ->
        :third_quarter

      d when d in 24..28 ->
        :waning_crescent

      d when d >= 29 ->
        :new_moon
    end
  end

  @doc """
  Returns remaining days to next new moon for the passed date using know new moon date and synodic month
  [https://en.wikipedia.org/wiki/Lunar_phase#Calculating_phase](https://en.wikipedia.org/wiki/Lunar_phase#Calculating_phase)

      iex> Solarex.Moon.days_to_new_moon(~D[2019-05-05])
      1
  """
  @spec days_to_new_moon(Date.t()) :: number()
  @synodic_month 29.530588853
  def days_to_new_moon(%Date{} = date) do
    days = julian_days(date) - julian_days(known_new_moon())

    cycles = Float.floor(days / @synodic_month)

    (days - cycles * @synodic_month)
    |> round()
  end

  @known_new_moon Application.get_env(:solarex, :known_new_moon)
  @spec known_new_moon() :: Date.t()
  defp known_new_moon() do
    Timex.parse!(@known_new_moon, "%Y-%m-%d", :strftime)
    |> Timex.to_date()
  end

  defp julian_days(%Date{year: year, month: month, day: day}) do
    Timex.Calendar.Julian.julian_date(year, month, day)
  end
end
