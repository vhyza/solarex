defmodule Solarex.Sun do
  import Solarex.Math

  @moduledoc """
  Solarex.Sun is module for calculating sunrise, sunset and solar noon for particular
  date, latitude and longitude
  """

  @doc """
  Returns sunrise for passed Date, latitude, longitude.

      iex> Solarex.Sun.rise(~D[2017-01-01], 50.0598054, 14.3251989)
      {:ok, ~N[2017-01-01 07:01:40.231]}
  """
  @spec rise(Date.t(), number(), number()) :: {:ok, DateTime.t()} | {:error, term()}
  def rise(%Date{} = date, latitude, longitude) do
    rise(timestamp(date), latitude, longitude)
  end

  @doc """
  Returns sunrise for passed timestamp in milliseconds, latitude and longitude.

      iex> Solarex.Sun.rise(1483228800000, 50.0598054, 14.3251989)
      {:ok, ~N[2017-01-01 07:01:40.231]}
  """
  @spec rise(integer(), number(), number()) :: {:ok, DateTime.t()} | {:error, term()}
  def rise(timestamp, latitude, longitude) do
    noon = noon(timestamp, longitude)
    rise_hour_angle = rise_hour_angle(noon, latitude)

    do_rise(noon, rise_hour_angle)
  end

  defp do_rise(noon, {:ok, rise_hour_angle}) do
    rise =
      (noon + rise_hour_angle * 4 * 1000 * 60)
      |> round()
      |> DateTime.from_unix!(:millisecond)
      |> DateTime.to_naive()

    {:ok, rise}
  end

  defp do_rise(_noon, {:error, reason}) do
    {:error, reason}
  end

  @doc """
  Returns sunset for passed Date, latitude, longitude.

      iex> Solarex.Sun.set(~D[2017-01-01], 50.0598054, 14.3251989)
      "2017-01-01T15:11:28.135+00:00"
  """
  @spec set(Date.t(), number(), number()) :: {:ok, DateTime.t()} | {:error, term()}
  def set(%Date{} = date, latitude, longitude) do
    set(timestamp(date), latitude, longitude)
  end

  @doc """
  Returns sunset for passed timestamp in milliseconds, latitude and longitude.

      iex> Solarex.Sun.set(1483228800000, 50.0598054, 14.3251989)
      {:ok, ~N[2017-01-01 15:11:28.135]}
  """
  @spec set(integer(), number(), number()) :: {:ok, DateTime.t()} | {:error, term()}
  def set(timestamp, latitude, longitude) do
    noon = noon(timestamp, longitude)
    rise_hour_angle = rise_hour_angle(noon, latitude)

    do_set(noon, rise_hour_angle)
  end

  defp do_set(noon, {:ok, rise_hour_angle}) do
    set =
      (noon - rise_hour_angle * 4 * 1000 * 60)
      |> round()
      |> DateTime.from_unix!(:millisecond)
      |> DateTime.to_naive()

    {:ok, set}
  end

  defp do_set(_noon, {:error, reason}) do
    {:error, reason}
  end

  @doc """
  Returns Timex.Duration of daylight for given Date, latitude and longitude.

      iex> Solarex.Sun.hours(~D[2017-06-13], 50.0598054, 14.3251989) |> Timex.Duration.to_hours
      16.333333333333332
  """
  @spec hours(Date.t(), number(), number()) :: Timex.Duration.t()
  def hours(%Date{} = date, latitude, _longitude) do
    timestamp = timestamp(date)

    rise_hour_angle(timestamp, latitude)
    |> do_hours(timestamp, latitude)
  end

  defp do_hours({:ok, delta}, _timestamp, _latitude) do
    (8 * -delta)
    |> round()
    |> Timex.Duration.from_minutes()
  end

  defp do_hours({:error, _}, timestamp, latitude) do
    timestamp
    |> century()
    |> declination()
    |> do_hours(latitude)
  end

  defp do_hours(delta, latitude) when latitude < 0 do
    case delta do
      delta when delta < 0.833 -> Timex.Duration.from_hours(24)
      _ -> Timex.Duration.from_hours(0)
    end
  end

  defp do_hours(delta, latitude) when latitude >= 0 do
    case delta do
      delta when delta > -0.833 -> Timex.Duration.from_hours(24)
      _ -> Timex.Duration.from_hours(0)
    end
  end

  @doc """
  Returns the time of the solar noon for Date, latitude and longitude.
  [https://en.wikipedia.org/wiki/Noon#Solar_noon](https://en.wikipedia.org/wiki/Noon#Solar_noon)

      iex> noon = Solarex.Sun.noon(~D[2017-01-01], 50.0598054, 14.3251989)
      ...> Timex.format!(noon, "{ISO:Extended}")
      "2017-01-01T11:06:34.183+00:00"
  """
  @spec noon(Date.t(), number(), number()) :: DateTime.t()
  def noon(%Date{} = date, _latitude, longitude) do
    noon(timestamp(date), longitude)
    |> round()
    |> DateTime.from_unix!(:millisecond)
  end

  @doc """
  Returns the unix timestamp in milliseconds of the solar noon for passed timestamp in milliseconds and longitude.
  [https://en.wikipedia.org/wiki/Noon#Solar_noon](https://en.wikipedia.org/wiki/Noon#Solar_noon)

      iex> Solarex.Sun.noon(1483228800000, 14.3251989)
      1483268794183
  """
  @spec noon(integer(), number()) :: integer()
  def noon(timestamp, longitude) do
    # First approximation
    t = century(timestamp + (12 - longitude * 24 / 360) * 3_600_000)

    # First correction
    o1 = 720 - longitude * 4 - equation_of_time(t - longitude / (360 * 36525))
    # Second correction
    o2 = 720 - longitude * 4 - equation_of_time(t + o1 / (1440 * 36525))

    (timestamp + o2 * 1000 * 60)
    |> round()
  end

  @doc """
  Returns the fraction number of centures since the J2000.0 epoch, 2000-01-01T12:00:00Z for passed unix timestamp in milliseconds.

      iex> Solarex.Sun.century(1483228800000.0)
      0.17000684462696783
  """
  @spec century(number()) :: float()
  def century(timestamp) when is_float(timestamp) do
    timestamp
    |> round()
    |> century()
  end

  @doc """
  Returns the fraction number of centures since the J2000.0 epoch, 2000-01-01T12:00:00Z for passed unix timestamp in milliseconds.

      iex> Solarex.Sun.century(1483228800000)
      0.17000684462696783
  """
  # number of miliseconds from 2000-01-01T12:00:00Z Etc/UTC
  @epoch 946_728_000_000
  def century(timestamp) when is_integer(timestamp) do
    (timestamp - @epoch) / 3_155_760_000_000
  end

  @doc """
  Returns hour angle of sunrise for the given unix timestamp and latitude in degrees.
  [https://en.wikipedia.org/wiki/Hour_angle](https://en.wikipedia.org/wiki/Hour_angle)

      iex> Solarex.Sun.rise_hour_angle(1497026562000, 37.7749)
      {:ok, -110.40483214814614}
  """
  @spec rise_hour_angle(integer(), number()) :: {:ok, float()} | {:error, term()}
  def rise_hour_angle(timestamp, latitude) do
    phi = radians(latitude)

    theta =
      timestamp
      |> century()
      |> declination()
      |> radians()

    case cos(radians(90.833)) / (cos(phi) * cos(theta)) - tan(phi) * tan(theta) do
      ratio when ratio > -1 and ratio < 1 -> {:ok, -degrees(acos(ratio))}
      ratio -> {:error, ":math.acos not defined for #{ratio}"}
    end
  end

  @doc """
  Returns the equation of time the for given t in J2000.0 centuries.
  [https://en.wikipedia.org/wiki/Equation_of_time](https://en.wikipedia.org/wiki/Equation_of_time)

      iex> Solarex.Sun.equation_of_time(0.17437909156589854)
      0.6590584715529293
  """
  @spec equation_of_time(number()) :: number()
  def equation_of_time(t) do
    epsilon = obliquity_of_ecliptic(t)
    l0 = mean_longitude(t)
    e = orbit_eccentricity(t)
    m = mean_anomaly(t)
    y = pow(tan(radians(epsilon) / 2), 2)
    sin2l0 = sin(2 * radians(l0))
    sinm = sin(radians(m))
    cos2l0 = cos(2 * radians(l0))
    sin4l0 = sin(4 * radians(l0))
    sin2m = sin(2 * radians(m))

    etime =
      y * sin2l0 - 2 * e * sinm + 4 * e * y * sinm * cos2l0 - 0.5 * y * y * sin4l0 -
        1.25 * e * e * sin2m

    degrees(etime) * 4
  end

  @doc """
  Returns the sun's equation of center for given t in J2000.0 centuries.
  [https://en.wikipedia.org/wiki/Equation_of_the_center](https://en.wikipedia.org/wiki/Equation_of_the_center)

      iex> Solarex.Sun.equation_of_center(0.17437909156589854)
      0.7934457966327464
  """
  @spec equation_of_center(number()) :: number()
  def equation_of_center(t) do
    m = radians(mean_anomaly(t))
    sinm = sin(m)
    sin2m = sin(m * 2)
    sin3m = sin(m * 3)

    sinm * (1.914602 - t * (0.004817 + 0.000014 * t)) + sin2m * (0.019993 - 0.000101 * t) +
      sin3m * 0.000289
  end

  @doc """
  Returns the solar declination in degrees for given t in J2000.0 centuries.
  [https://en.wikipedia.org/wiki/Position_of_the_Sun#Declination_of_the_Sun_as_seen_from_Earth](https://en.wikipedia.org/wiki/Position_of_the_Sun#Declination_of_the_Sun_as_seen_from_Earth)

      iex> Solarex.Sun.declination(0.17437909156589854)
      22.982073772785167
  """
  @spec declination(number()) :: number()
  def declination(t) do
    degrees(asin(sin(radians(obliquity_of_ecliptic(t))) * sin(radians(apparent_longitude(t)))))
  end

  @doc """
  Returns the obliquity of the Earth’s ecliptic in degrees for given t in J2000.0 centuries.
  [https://en.wikipedia.org/wiki/Ecliptic#Obliquity_of_the_ecliptic](https://en.wikipedia.org/wiki/Ecliptic#Obliquity_of_the_ecliptic)

      iex> Solarex.Sun.obliquity_of_ecliptic(0.17437909156589854)
      23.43485798269169
  """
  @spec obliquity_of_ecliptic(number()) :: number()
  def obliquity_of_ecliptic(t) do
    e0 = 23 + (26 + (21.448 - t * (46.815 + t * (0.00059 - t * 0.001813))) / 60) / 60
    omega = 125.04 - 1934.136 * t

    e0 + 0.00256 * cos(radians(omega))
  end

  @doc """
  Returns the sun's mean longitude in degrees for given t in J2000.0 centuries.
  [https://en.wikipedia.org/wiki/Mean_longitude](https://en.wikipedia.org/wiki/Mean_longitude)

      iex> Solarex.Sun.mean_longitude(0.17437909156589854)
      78.24800784813306
  """
  @spec mean_longitude(number()) :: number()
  def mean_longitude(t) do
    l = modulo(280.46646 + t * (36000.76983 + t * 0.0003032), 360)

    get_mean_longitude(l)
  end

  defp get_mean_longitude(l) when l < 0, do: l + 360
  defp get_mean_longitude(l), do: l

  @doc """
  Returns the sun's true longitude in degrees for given t in J2000.0 centuries.
  [https://en.wikipedia.org/wiki/True_longitude](https://en.wikipedia.org/wiki/True_longitude)

    iex> Solarex.Sun.true_longitude(0.17437909156589854)
    79.04145364476581
  """
  @spec true_longitude(number()) :: number()
  def true_longitude(t) do
    mean_longitude(t) + equation_of_center(t)
  end

  @doc """
  Returns the sun's apparent longitude in degrees for given t in J2000.0 centuries.
  [https://en.wikipedia.org/wiki/Apparent_longitude](https://en.wikipedia.org/wiki/Apparent_longitude)

      iex> Solarex.Sun.apparent_longitude(0.17437909156589854)
      79.0332141755133
  """
  @spec apparent_longitude(number()) :: number()
  def apparent_longitude(t) do
    true_longitude(t) - 0.00569 - 0.00478 * sin(radians(125.04 - 1934.136 * t))
  end

  @doc """
  Returns the sun's mean anomaly in degrees for given t in J2000.0 centuries.
  [https://en.wikipedia.org/wiki/Mean_anomaly](https://en.wikipedia.org/wiki/Mean_anomaly)

      iex> Solarex.Sun.mean_anomaly(0.17437909156589854)
      6635.010792131577
  """
  @spec mean_anomaly(number()) :: number()
  def mean_anomaly(t) do
    357.52911 + t * (35999.05029 - 0.0001537 * t)
  end

  @doc """
  Returns eccentricity for given t in J2000.0 centuries.
  [https://en.wikipedia.org/wiki/Orbital_eccentricity](https://en.wikipedia.org/wiki/Orbital_eccentricity)

      iex> Solarex.Sun.orbit_eccentricity(0.17437909156589854)
      0.016701299773425684
  """
  @spec orbit_eccentricity(number()) :: number()
  def orbit_eccentricity(t) do
    0.016708634 - t * (0.000042037 + 0.0000001267 * t)
  end

  defp timestamp(%Date{} = date) do
    Timex.to_unix(date) * 1000
  end
end
