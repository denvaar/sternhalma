defmodule Sternhalma.Pathfinding do
  @moduledoc """
  Provides functions for pathfinding in the context of a game board.

  Pathfinding comes into play when determining if a proposed move is valid.

  A path is considered valid if:

    - The finishing cell is empty and a direct neighbor of the starting cell
    - The finishing cell is empty and is reachable via one or more "jump" moves

  A jump is only possible if there's a marble in between the current cell and
  an empty cell.

  Marbles can be jumped any number of times, as long as the direction of the jump
  doesn't change while not on an empty cell. It is valid to change directions
  once an empty cell is reached.
  """

  alias Sternhalma.{Hex, Cell, Board}

  @doc """
  Find and return a list of cells between the given
  start and finish cells.

  If there is not a valid path between the two, an empty
  list is returned.

  The shortest path possible is returned.
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
        path = bfs(board, finish, %{start => :done}, %{start => true}, [start])
        backtrack(path, finish, [])
    end
  end

  @type path :: %{Cell.t() => :done | Cell.t()}
  @type visited :: %{Hex.t() => true}

  @spec bfs(Board.t(), Cell.t(), path(), visited(), list(Cell.t())) :: path()
  defp bfs(_board, target, path, _visited, [current | _to_be_explored])
       when current.position == target.position,
       do: path

  defp bfs(_board, _target, path, _visited, []), do: path

  defp bfs(board, target, path, visited, [current | to_be_explored]) do
    neighbors =
      current.position
      |> jumpable_neighbors(board)
      |> remove_visited_cells(visited)

    path =
      Enum.reduce(neighbors, path, fn neighbor, path_acc ->
        Map.put(path_acc, neighbor, current)
      end)

    visited =
      Enum.reduce(neighbors, visited, fn neighbor, visited_acc ->
        Map.put(visited_acc, neighbor.position, true)
      end)

    bfs(board, target, path, visited, to_be_explored ++ neighbors)
  end

  @doc """
  Return the cells that are reachable one jump move
  away from the given position.

  See Hex.neighbors/1 or Hex.neighbor/2 for finding
  neighbors in general.
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

  @spec backtrack(path(), nil | Cell.t() | :done, list(Cell.t())) :: list(Cell.t())
  defp backtrack(_path, nil, _result), do: []
  defp backtrack(_path, :done, result), do: result

  defp backtrack(path, finish, result) do
    current = Map.get(path, finish)
    backtrack(path, current, [finish | result])
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
