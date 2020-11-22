defmodule Sternhalma.Hex do
  @moduledoc """
  Represents x z y

     x  z
      y
  """

  defstruct x: 0, z: 0, y: 0

  def new({x, z, y}) when x + z + y != 0, do: nil

  def new({x, z, y}) do
    %__MODULE__{x: x, z: z, y: y}
  end

  def neighbor(hex, :top_left), do: %__MODULE__{x: hex.x, z: hex.z - 1, y: hex.y + 1}
  def neighbor(hex, :top_right), do: %__MODULE__{x: hex.x + 1, z: hex.z - 1, y: hex.y}
  def neighbor(hex, :left), do: %__MODULE__{x: hex.x - 1, z: hex.z, y: hex.y + 1}
  def neighbor(hex, :right), do: %__MODULE__{x: hex.x + 1, z: hex.z, y: hex.y - 1}
  def neighbor(hex, :bottom_left), do: %__MODULE__{x: hex.x - 1, z: hex.z + 1, y: hex.y}
  def neighbor(hex, :bottom_right), do: %__MODULE__{x: hex.x, z: hex.z + 1, y: hex.y - 1}

  def neighbors(hex) do
    [:top_left, :top_right, :left, :right, :bottom_left, :bottom_right]
    |> Enum.map(fn direction -> neighbor(hex, direction) end)
  end

  def to_pixel(hex) do
    size = 1
    origin_x = 10
    origin_y = 10

    x = (:math.sqrt(3.0) * hex.x + :math.sqrt(3.0) / 2.0 * hex.z) * size
    y = (0.0 * hex.x + 3.0 / 2.0 * hex.z) * size
    {x + origin_x, y + origin_y}
  end

  def from_pixel({px, py}) do
    size = 1
    origin_x = 10
    origin_y = 10

    # r = z, q = x, s = y
    pt_x = (px - origin_x) / size
    pt_y = (py - origin_y) / size

    x = :math.sqrt(3.0) / 3.0 * pt_x + -1.0 / 3.0 * pt_y
    z = 0.0 * pt_x + 2.0 / 3.0 * pt_y

    hex_round(x, z, -x - z)
  end

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
