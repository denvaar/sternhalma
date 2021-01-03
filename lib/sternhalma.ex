defmodule Sternhalma do
  @moduledoc """
  """

  alias Sternhalma.{Board, Cell, Pathfinding, Hex}

  @doc """
  Return {x, y} pixel coordinates for a given Hex coordinate.

  ## Examples

      iex> to_pixel(Sternhalma.Hex.new({1, -4, 3}))
      {8.267949192431123, 4.0}


  """
  @spec to_pixel(Hex.t()) :: {number(), number()}
  defdelegate to_pixel(position), to: Hex

  @doc """
  Return Hex coordinate for a given pixel coordinate {x, y}.

  ## Examples

      iex> from_pixel({8.267949192431123, 4.0})
      %Sternhalma.Hex{x: 1, y: 3, z: -4}


  """
  @spec from_pixel({number(), number()}) :: Hex.t()
  defdelegate from_pixel(position), to: Hex

  @doc """
  Move a marble from one cell on the board to another.
  The function does not take into account if there is a
  valid path between the two cells.
  """
  @spec move_marble(Board.t(), String.t(), Cell.t(), Cell.t()) :: Board.t()
  def move_marble(board, marble, from, to) do
    Enum.map(board, fn cell ->
      cond do
        cell.position == from.position ->
          Cell.set_marble(cell, nil)

        cell.position == to.position ->
          Cell.set_marble(cell, marble)

        true ->
          cell
      end
    end)
  end

  @doc """
  Return a list of board cells from one position to another.
  Returns an empty list if there is no path possible.
  """
  @spec find_path(Board.t(), Cell.t(), Cell.t()) :: list(Cell.t())
  def find_path(board, from, to) do
    Pathfinding.path(board, from, to)
  end

  @doc """
  Generate an empty board.
  """
  @spec empty_board() :: Board.t()
  defdelegate empty_board(), to: Board, as: :empty

  @doc """
  Return a cell from the game board based on pixel coordinates, x and y.
  Return nil if the cell does not exist.


  ## Examples

      iex> get_board_cell(empty_board(), {17.794, 14.5})
      {:ok, %Sternhalma.Cell{marble: nil, position: %Sternhalma.Hex{x: 3, y: -6, z: 3}}}

      iex> get_board_cell(empty_board(), {172.794, -104.5})
      {:error, nil}


  """
  @spec get_board_cell(Board.t(), {number(), number()}) :: {:ok | :error, Cell.t() | nil}
  defdelegate get_board_cell(board, position), to: Board

  @doc """
  Add new marbles to the board.

  The location of the marbles being added is determined based
  on the number of unique marbles that are already on the board.
  """
  @spec setup_marbles(Board.t(), String.t()) :: {:ok, Board.t()} | {:error, :board_full}
  def setup_marbles(board, marble) do
    unique_existing_marble_count = Board.count_marbles(board)

    with {:ok, triangle_location} <- Board.position_opponent(unique_existing_marble_count) do
      {:ok,
       Board.setup_triangle(
         board,
         triangle_location,
         marble
       )}
    else
      {:error, _} ->
        {:error, :board_full}
    end
  end

  @doc """
  Return the list of unique marbles found on a game board.
  """
  @spec unique_marbles(Board.t()) :: list(String.t())
  defdelegate unique_marbles(board), to: Board

  @doc """
  Indicates if all the marbles of the given type are located
  in their winning locations.
  """
  @spec won_game?(Board.t(), String.t()) :: boolean()
  def won_game?(board, marble) do
    Board.find_winners(board)
    |> Enum.any?(&(&1.marble == marble))
  end

  @doc """
  Returns the winner, if there is one.
  To win, all 10 marbles must be in their
  target positions.
  """
  @spec winner(Board.t()) :: String.t() | nil
  def winner(board) do
    with [[winner | _] | _] <- Board.find_winners(board) do
      winner.marble
    else
      _ ->
        nil
    end
  end
end
