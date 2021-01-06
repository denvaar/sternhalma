defmodule Sternhalma.Pathfinding do
  @moduledoc """
  Provides functions to find paths between positions on the Chinese Checkers game board.

  A path is found if either:
    - The finishing spot is empty and is a direct neighbor of the starting spot.
    - The finishing spot is empty and is reachable via one or more "jump" moves.

  """

  alias Sternhalma.{Hex, Cell, Board}

  @doc """
  Return a list of cells from start to finish.
  Returns an empty list if there is no path.
  """
  @spec path(Board.t(), Cell.t(), Cell.t()) :: list(Cell.t())
  def path(_board, start, finish)
      when start.position == finish.position or start.marble == nil or finish.marble != nil,
      do: []

  def path(board, start, finish) do
    case jump_needed?(start, finish) do
      false ->
        [start, finish]

      true ->
        path = bfs(board, finish, %{start => :done}, %{start => true}, :done, [start])
        IO.inspect(path)
        backtrack(path, finish, [])
    end
  end

  @type path :: %{Cell.t() => :done | Cell.t()}
  @type visited :: %{Hex.t() => true}

  @doc """
  Find the shorted path to the provided target
  cell, if exists.

  The general algorithm is
  Breadth First Search. First dequeue a cell
  for exploration, next enqueue neighbors and
  repeat.
  """
  @spec bfs(Board.t(), Cell.t(), path(), visited(), Cell.t() | :done, list(Cell.t())) :: path()
  defp bfs(_board, target, path, _visited, parent, [current | _to_be_explored])
       when current.position == target.position,
       do: Map.put(path, current, parent)

  defp bfs(_board, _target, path, _visited, _parent, []), do: path

  defp bfs(board, target, path, visited, parent, [current | to_be_explored]) do
    neighbor_cells =
      current.position
      |> jumpable_neighbors(board)
      |> remove_invalid_cells(board)
      |> remove_visited_cells(visited)

    path =
      Enum.reduce(neighbor_cells, path, fn cell, path_acc ->
        Map.put(path_acc, cell, current)
      end)

    visited =
      Enum.reduce(neighbor_cells, visited, fn cell, visited_acc ->
        Map.put(visited_acc, cell.position, true)
      end)

    bfs(board, target, path, visited, current, to_be_explored ++ neighbor_cells)
  end

  @doc """
  Return all the neighbors from a given position
  on a board. It's different from Hex.neighbors
  because this counts neighbors as either:

  - Empty cells directly next to the given position
  - Empty cells that are one jump away from the given
    position from a single direction

  This function is helpful because from this module's
  perspective the only neighbors that are important
  are those that are reachable.

  See Hex.neighbors/1 or Hex.neighbor/2 for finding
  neighbors without these rules.
  """
  @spec jumpable_neighbors(Hex.t(), Board.t()) :: list(Cell.t())
  def jumpable_neighbors(position, board) do
    position
    |> Hex.neighbors()
    |> Enum.map(fn {direction, position} ->
      case Enum.find(board, &(&1.position == position and &1.marble != nil)) do
        nil ->
          nil

        cell ->
          pos = Hex.neighbor(cell.position, direction)
          Enum.find(board, &(&1.position == pos and &1.marble == nil))
      end
    end)
    |> Enum.filter(& &1)
  end

  # @spec backtrack(path_guide(), next_location(), list(Cell.t())) :: list(Cell.t())
  defp backtrack(_path, nil, _result), do: []
  defp backtrack(_path, :done, result), do: result

  defp backtrack(path, finish, result) do
    current = Map.get(path, finish)
    # IO.inspect(current)
    backtrack(path, current, [finish | result])
  end

  # TODO: might not need this

  @spec remove_invalid_cells(list(Cell.t()), Board.t()) :: list(Cell.t())
  defp remove_invalid_cells(neighbors, board) do
    neighbors
    |> Enum.filter(fn neighbor_cell ->
      Enum.any?(board, fn cell -> neighbor_cell.position == cell.position end)
    end)
  end

  @spec remove_visited_cells(list(Cell.t()), visited()) :: list(Cell.t())
  defp remove_visited_cells(neighbors, visited) do
    neighbors
    |> Enum.reject(fn cell -> Map.get(visited, cell.position) end)
  end

  @spec jump_needed?(Cell.t(), Cell.t()) :: boolean()
  defp jump_needed?(start, finish) do
    neighbors = Hex.neighbors(start.position)

    !(finish.marble == nil and
        Enum.find(neighbors, fn {_direction, hex} ->
          hex == finish.position
        end))
  end
end
