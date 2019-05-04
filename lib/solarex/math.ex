defmodule Solarex.Math do
  defdelegate acos(x), to: :math
  defdelegate sin(x), to: :math
  defdelegate tan(x), to: :math
  defdelegate asin(x), to: :math
  defdelegate cos(x), to: :math
  defdelegate pi(), to: :math
  defdelegate pow(x, y), to: :math

  @doc """
  Calculates radians from degrees

      iex> Solarex.Math.radians(57.295779513082321)
      1.0
  """
  @spec radians(number()) :: float()
  def radians(degrees) do
    pi() * degrees / 180
  end

  @doc """
  Calculates degrees from radians

      iex> Solarex.Math.degrees(1)
      57.29577951308232
  """
  @spec degrees(number()) :: float()
  def degrees(radians) do
    180 * radians / pi()
  end

  @doc """
  Calculates the remainder after division of one x by y

      iex> Solarex.Math.modulo(19, 3)
      1.0
  """
  @spec modulo(number(), number()) :: float()
  def modulo(x, y) do
    r = x / y
    x - Float.floor(r) * y
  end
end
