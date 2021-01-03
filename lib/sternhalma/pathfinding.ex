defmodule Sternhalma.Pathfinding do
  @moduledoc """
  Provides functions to find paths between positions on the Chinese Checkers game board.

  A path is found if either:
    - The finishing spot is empty and is a direct neighbor of the starting spot.
    - The finishing spot is empty and is reachable via one or more "jump" moves.

  TODO: explain jump moves
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
        paths =
          jump_move(
            board,
            start,
            finish,
            %{start => :done},
            [{nil, start}]
          )

        backtrack(paths, finish, [])
    end
  end

  @type next_location :: nil | :done | Cell.t()

  @typedoc """
  Represents the chain of steps needed to create a path of cells.
  The keys are always cells and the values can be:
    - A cell when there is another location to move to
    - :done when the desired location is reached
    - nil when the location is invalid
  """
  @type path_guide :: %{Cell.t() => next_location()}

  @spec backtrack(path_guide(), next_location(), list(Cell.t())) :: list(Cell.t())
  defp backtrack(_paths, nil, _path), do: []
  defp backtrack(_paths, :done, path), do: path

  defp backtrack(paths, finish, path) do
    current = Map.get(paths, finish)
    backtrack(paths, current, [finish | path])
  end

  @type jump_direction :: nil | Hex.direction()

  @spec jump_move(Board.t(), Cell.t(), Cell.t(), path_guide(), list({jump_direction(), Cell.t()})) ::
          path_guide()
  defp jump_move(_board, _start, _finish, came_from, []), do: came_from

  defp jump_move(_board, _start, finish, came_from, [{_direction, current} | _cells])
       when finish.position == current.position do
    came_from
  end

  defp jump_move(board, start, finish, came_from, [{direction, current} | cells]) do
    neighboring_cells =
      current
      |> neighbors(direction)
      |> remove_invalid_cells(board)
      |> convert_hex_positions_to_cells(board)
      |> filter_occupied_cells(direction)
      |> remove_visited_cells(came_from)

    next_cells =
      neighboring_cells
      |> Enum.filter(fn {_, c} -> Enum.find(cells, fn {_, cc} -> cc == c end) == nil end)
      |> Kernel.++(cells)

    came_from =
      update_came_from(
        came_from,
        current,
        Enum.map(next_cells, fn {_direction, cell} -> cell end)
      )

    jump_move(board, start, finish, came_from, next_cells)
  end

  @spec update_came_from(path_guide(), Cell.t(), list(Cell.t())) :: path_guide()
  defp update_came_from(came_from, current, next_cells) do
    with [next_neighbor | _] <- next_cells do
      Map.put(came_from, next_neighbor, current)
    else
      _ -> came_from
    end
  end

  @spec convert_hex_positions_to_cells(list({jump_direction(), Hex.t()}), Board.t()) ::
          list({jump_direction(), Cell.t()})
  defp convert_hex_positions_to_cells(neighbors, board) do
    Enum.reduce(neighbors, [], fn {direction, position}, acc ->
      case Enum.find(board, &(&1.position == position)) do
        nil ->
          acc

        cell ->
          [{direction, cell} | acc]
      end
    end)
  end

  @spec neighbors(Cell.t(), jump_direction()) :: list({jump_direction(), Hex.t()})
  defp neighbors(cell, nil), do: Hex.neighbors(cell.position)
  defp neighbors(cell, direction), do: [{nil, Hex.neighbor(cell.position, direction)}]

  @spec remove_invalid_cells(list({jump_direction(), Hex.t()}), Board.t()) ::
          list({jump_direction(), Hex.t()})
  defp remove_invalid_cells(neighbors, board) do
    neighbors
    |> Enum.filter(fn {_direction, neighbor} ->
      Enum.any?(board, fn cell -> neighbor == cell.position end)
    end)
  end

  @spec remove_visited_cells(list({jump_direction(), Cell.t()}), path_guide()) ::
          list({jump_direction(), Cell.t()})
  defp remove_visited_cells(cells, came_from) do
    cells
    |> Enum.reject(fn {_direction, cell} -> Map.get(came_from, cell) end)
  end

  @spec filter_occupied_cells(list({jump_direction(), Cell.t()}), jump_direction()) ::
          list({jump_direction(), Cell.t()})
  defp filter_occupied_cells(cells, nil) do
    Enum.reject(cells, fn {_direction, cell} ->
      cell.marble == nil
    end)
  end

  defp filter_occupied_cells(cells, _direction) do
    Enum.filter(cells, fn {_direction, cell} ->
      cell.marble == nil
    end)
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
