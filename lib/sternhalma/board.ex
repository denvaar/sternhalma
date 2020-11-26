defmodule Sternhalma.Board do
  @moduledoc """
  Provides functions to manipulate the Chinese Checkers game board.
  """

  alias Sternhalma.{Hex, Cell}

  @type t :: list(Cell.t())

  @doc """
  Generate an empty board.
  """
  @spec empty() :: list(Cell.t())
  def empty() do
    six_point_star()
    |> Enum.map(&%Cell{position: &1})
  end

  @type home_triangle ::
          :top_left
          | :top
          | :top_right
          | :bottom_left
          | :bottom
          | :bottom_right

  @doc """
  Fill in a home triangle with marbles.
  """
  @spec setup_triangle(t(), home_triangle(), char()) :: t()
  def setup_triangle(board, :bottom_left, _marble) do
    # x = [
    #   make_row({3, -6, 3}, 1),
    #   make_row({2, -5, 3}, 2),
    #   make_row({1, -4, 3}, 3),
    #   make_row({0, -3, 3}, 4),
    # ]
    # |> List.flatten()
    #
    # Enum.map(board, fn cell ->
    #   Enum.
    #   %Cell{marble: marble, position: position}
    # end)

    board
  end

  @spec six_point_star() :: list(Hex.t())
  defp six_point_star() do
    # left -> right, bottom -> top
    [
      make_row({3, -6, 3}, 1),
      make_row({2, -5, 3}, 2),
      make_row({1, -4, 3}, 3),
      make_row({0, -3, 3}, 4),
      make_row({-5, -2, 7}, 13),
      make_row({-5, -1, 6}, 12),
      make_row({-5, 0, 5}, 11),
      make_row({-5, 1, 4}, 10),
      make_row({-5, 2, 3}, 9),
      make_row({-6, 3, 3}, 10),
      make_row({-7, 4, 3}, 11),
      make_row({-8, 5, 3}, 12),
      make_row({-9, 6, 3}, 13),
      make_row({-5, 7, -2}, 4),
      make_row({-5, 8, -3}, 3),
      make_row({-5, 9, -4}, 2),
      make_row({-5, 10, -5}, 1)
    ]
    |> List.flatten()
  end

  @spec make_row({number(), number(), number()}, number()) :: list(Hex.t())
  defp make_row({x, z, y}, length) do
    [
      Enum.to_list(x..(length + x - 1)),
      List.duplicate(z, length),
      Enum.to_list(y..(y - (length - 1)))
    ]
    |> Enum.zip()
    |> Enum.map(&Hex.new(&1))
  end
end
