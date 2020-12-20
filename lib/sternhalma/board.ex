defmodule Sternhalma.Board do
  @moduledoc """
  Provides functions to manipulate the Chinese Checkers game board.
  """

  alias Sternhalma.{Hex, Cell}

  @type t :: list(Cell.t())

  @doc """
  Generate an empty board.
  """
  @spec empty() :: t()
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
  @spec setup_triangle(t(), home_triangle(), String.t()) :: t()
  def setup_triangle(board, :bottom, marble) do
    positions = [
      %Hex{x: 3, y: 3, z: -6},
      %Hex{x: 2, y: 3, z: -5},
      %Hex{x: 3, y: 2, z: -5},
      %Hex{x: 1, y: 3, z: -4},
      %Hex{x: 2, y: 2, z: -4},
      %Hex{x: 3, y: 1, z: -4},
      %Hex{x: 0, y: 3, z: -3},
      %Hex{x: 1, y: 2, z: -3},
      %Hex{x: 2, y: 1, z: -3},
      %Hex{x: 3, y: 0, z: -3}
    ]

    setup_triangle_helper(board, positions, marble)
  end

  def setup_triangle(board, :bottom_left, marble) do
    positions = [
      %Hex{x: -5, y: 7, z: -2},
      %Hex{x: -5, y: 6, z: -1},
      %Hex{x: -4, y: 6, z: -2},
      %Hex{x: -5, y: 5, z: 0},
      %Hex{x: -4, y: 5, z: -1},
      %Hex{x: -3, y: 5, z: -2},
      %Hex{x: -5, y: 4, z: 1},
      %Hex{x: -4, y: 4, z: 0},
      %Hex{x: -3, y: 4, z: -1},
      %Hex{x: -2, y: 4, z: -2}
    ]

    setup_triangle_helper(board, positions, marble)
  end

  def setup_triangle(board, :top_left, marble) do
    positions = [
      %Hex{x: -9, y: 3, z: 6},
      %Hex{x: -8, y: 2, z: 6},
      %Hex{x: -8, y: 3, z: 5},
      %Hex{x: -7, y: 1, z: 6},
      %Hex{x: -7, y: 2, z: 5},
      %Hex{x: -7, y: 3, z: 4},
      %Hex{x: -6, y: 0, z: 6},
      %Hex{x: -6, y: 1, z: 5},
      %Hex{x: -6, y: 2, z: 4},
      %Hex{x: -6, y: 3, z: 3}
    ]

    setup_triangle_helper(board, positions, marble)
  end

  def setup_triangle(board, :top, marble) do
    positions = [
      %Hex{x: -5, y: -5, z: 10},
      %Hex{x: -5, y: -4, z: 9},
      %Hex{x: -4, y: -5, z: 9},
      %Hex{x: -5, y: -3, z: 8},
      %Hex{x: -4, y: -4, z: 8},
      %Hex{x: -3, y: -5, z: 8},
      %Hex{x: -5, y: -2, z: 7},
      %Hex{x: -4, y: -3, z: 7},
      %Hex{x: -3, y: -4, z: 7},
      %Hex{x: -2, y: -5, z: 7}
    ]

    setup_triangle_helper(board, positions, marble)
  end

  def setup_triangle(board, :top_right, marble) do
    positions = [
      %Hex{x: 3, y: -9, z: 6},
      %Hex{x: 2, y: -8, z: 6},
      %Hex{x: 3, y: -8, z: 5},
      %Hex{x: 1, y: -7, z: 6},
      %Hex{x: 2, y: -7, z: 5},
      %Hex{x: 3, y: -7, z: 4},
      %Hex{x: 0, y: -6, z: 6},
      %Hex{x: 1, y: -6, z: 5},
      %Hex{x: 2, y: -6, z: 4},
      %Hex{x: 3, y: -6, z: 3}
    ]

    setup_triangle_helper(board, positions, marble)
  end

  def setup_triangle(board, :bottom_right, marble) do
    positions = [
      %Hex{x: 7, y: -5, z: -2},
      %Hex{x: 6, y: -5, z: -1},
      %Hex{x: 6, y: -4, z: -2},
      %Hex{x: 5, y: -5, z: 0},
      %Hex{x: 5, y: -4, z: -1},
      %Hex{x: 5, y: -3, z: -2},
      %Hex{x: 4, y: -5, z: 1},
      %Hex{x: 4, y: -4, z: 0},
      %Hex{x: 4, y: -3, z: -1},
      %Hex{x: 4, y: -2, z: -2}
    ]

    setup_triangle_helper(board, positions, marble)
  end

  @doc """
  Return a cell from the game board based on pixel coordinates, x and y.
  Return nil if the cell does not exist.


  ## Examples

      iex> get_board_cell(empty(), {17.794, 14.5})
      {:ok, %Sternhalma.Cell{marble: nil, position: %Sternhalma.Hex{x: 3, y: -6, z: 3}}}

      iex> get_board_cell(empty(), {172.794, -104.5})
      {:error, nil}


  """
  @spec get_board_cell(t(), {number(), number()}) :: {:ok | :error, Cell.t() | nil}
  def get_board_cell(board, pixel_coord) do
    case Enum.find(board, fn cell ->
           cell.position == Hex.from_pixel(pixel_coord)
         end) do
      nil -> {:error, nil}
      board_cell -> {:ok, board_cell}
    end
  end

  @spec setup_triangle_helper(t(), list(Hex.t()), String.t()) :: t()
  defp setup_triangle_helper(board, target_positions, marble) do
    board
    |> Enum.map(fn cell ->
      if Enum.any?(target_positions, fn position ->
           position == cell.position
         end) do
        %Cell{marble: marble, position: cell.position}
      else
        cell
      end
    end)
  end

  @spec six_point_star() :: list(Hex.t())
  defp six_point_star() do
    # left -> right, bottom -> top
    [
      {{3, -6, 3}, 1},
      {{2, -5, 3}, 2},
      {{1, -4, 3}, 3},
      {{0, -3, 3}, 4},
      {{-5, -2, 7}, 13},
      {{-5, -1, 6}, 12},
      {{-5, 0, 5}, 11},
      {{-5, 1, 4}, 10},
      {{-5, 2, 3}, 9},
      {{-6, 3, 3}, 10},
      {{-7, 4, 3}, 11},
      {{-8, 5, 3}, 12},
      {{-9, 6, 3}, 13},
      {{-5, 7, -2}, 4},
      {{-5, 8, -3}, 3},
      {{-5, 9, -4}, 2},
      {{-5, 10, -5}, 1}
    ]
    |> Enum.map(fn {coords, row_length} ->
      make_row(coords, row_length)
    end)
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

  @doc """
  Return the list of unique marbles found on a game board.
  """
  def unique_marbles(board) do
    {_, marbles} =
      Enum.reduce(board, {%{}, []}, fn cell, {memory, marbles} ->
        if cell.marble != nil and Map.get(memory, cell.marble) == nil do
          {Map.put(memory, cell.marble, true), [cell.marble | marbles]}
        else
          {memory, marbles}
        end
      end)

    marbles
  end

  @spec count_marbles(t()) :: number()
  def count_marbles(board) do
    board
    |> unique_marbles()
    |> Enum.count()
  end

  @spec position_opponent(0..5) :: {:ok, home_triangle()} | {:error, nil}
  def position_opponent(0), do: {:ok, :top}
  def position_opponent(1), do: {:ok, :bottom}
  def position_opponent(2), do: {:ok, :top_left}
  def position_opponent(3), do: {:ok, :bottom_right}
  def position_opponent(4), do: {:ok, :top_right}
  def position_opponent(5), do: {:ok, :bottom_left}
  def position_opponent(_), do: {:error, nil}
end
