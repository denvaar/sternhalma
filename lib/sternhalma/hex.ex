defmodule Sternhalma.Hex do
  alias __MODULE__

  defstruct x: 0, z: 0, y: 0

  @typedoc """
  Represents x z y.

  The coordinates x, z, and y must add to 0 in some way.

  See https://www.redblobgames.com/grids/hexagons/#coordinates-cube for more info.
  """
  @type t :: %Hex{x: number(), z: number(), y: number()}

  @type direction ::
          :top_left
          | :top_right
          | :left
          | :right
          | :bottom_left
          | :bottom_right

  @doc """
  Return a new Hex struct with coordinates x, z, and y.
  Return nil if the coordinates provided do not add to 0.
  """
  @spec new({number(), number(), number()}) :: nil | t()
  def new({x, z, y}) when x + z + y != 0, do: nil

  def new({x, z, y}) do
    %Hex{x: x, z: z, y: y}
  end

  @doc """
  Return the next Hex coordinate based on a provided direction.

  ## Examples

      iex> neighbor(Sternhalma.Hex.new({1, -4, 3}), :top_left)
      %Sternhalma.Hex{x: 0, y: 3, z: -3}


  """
  @spec neighbor(t(), direction()) :: t()
  def neighbor(hex, :bottom_left), do: %Hex{x: hex.x, z: hex.z - 1, y: hex.y + 1}
  def neighbor(hex, :bottom_right), do: %Hex{x: hex.x + 1, z: hex.z - 1, y: hex.y}
  def neighbor(hex, :left), do: %Hex{x: hex.x - 1, z: hex.z, y: hex.y + 1}
  def neighbor(hex, :right), do: %Hex{x: hex.x + 1, z: hex.z, y: hex.y - 1}
  def neighbor(hex, :top_left), do: %Hex{x: hex.x - 1, z: hex.z + 1, y: hex.y}
  def neighbor(hex, :top_right), do: %Hex{x: hex.x, z: hex.z + 1, y: hex.y - 1}

  @doc """
  Return the surrounding Hex coordinates.

  ## Examples

      iex> neighbors(Sternhalma.Hex.new({1, -4, 3}))
      [
        top_left: %Sternhalma.Hex{x: 0, y: 3, z: -3},
        top_right: %Sternhalma.Hex{x: 1, y: 2, z: -3},
        left: %Sternhalma.Hex{x: 0, y: 4, z: -4},
        right: %Sternhalma.Hex{x: 2, y: 2, z: -4},
        bottom_left: %Sternhalma.Hex{x: 1, y: 4, z: -5},
        bottom_right: %Sternhalma.Hex{x: 2, y: 3, z: -5}
      ]

  """
  @spec neighbors(t()) :: list({direction(), t()})
  def neighbors(hex) do
    [:top_left, :top_right, :left, :right, :bottom_left, :bottom_right]
    |> Enum.map(fn direction -> {direction, neighbor(hex, direction)} end)
  end

  @doc """
  Return {x, y} pixel coordinates for a given Hex coordinate.

  ## Examples

      iex> to_pixel(Sternhalma.Hex.new({1, -4, 3}))
      {8.267949192431123, 4.0}


  """
  @spec to_pixel(t()) :: {number(), number()}
  def to_pixel(hex) do
    size = 1
    origin_x = 10
    origin_y = 10

    x = (:math.sqrt(3.0) * hex.x + :math.sqrt(3.0) / 2.0 * hex.z) * size
    y = (0.0 * hex.x + 3.0 / 2.0 * hex.z) * size
    {x + origin_x, y + origin_y}
  end

  @doc """
  Return Hex coordinate for a given pixel coordinate {x, y}.

  ## Examples

      iex> from_pixel({8.267949192431123, 4.0})
      %Sternhalma.Hex{x: 1, y: 3, z: -4}


  """
  @spec from_pixel({number(), number()}) :: t()
  def from_pixel({px, py}) do
    size = 1
    origin_x = 10
    origin_y = 10

    pt_x = (px - origin_x) / size
    pt_y = (py - origin_y) / size

    x = :math.sqrt(3.0) / 3.0 * pt_x + -1.0 / 3.0 * pt_y
    z = 0.0 * pt_x + 2.0 / 3.0 * pt_y

    hex_round(x, z, -x - z)
  end

  @spec hex_round(number(), number(), number()) :: t()
  defp hex_round(raw_x, raw_z, raw_y) do
    x = round(raw_x)
    z = round(raw_z)
    y = round(raw_y)

    x_diff = abs(x - raw_x)
    z_diff = abs(z - raw_z)
    y_diff = abs(y - raw_y)

    cond do
      x_diff > z_diff and x_diff > y_diff ->
        new({-z - y, z, y})

      z_diff > y_diff ->
        new({x, -x - y, y})

      true ->
        new({x, z, -x - z})
    end
  end
end
