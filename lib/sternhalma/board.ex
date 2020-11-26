defmodule Sternhalma.Board do
  @moduledoc """
  Provides functions to manipulate the Chinese Checkers game board.
  """

  alias Sternhalma.{Hex, Cell}

  @type t :: list(Cell.t())

  @doc """
  Generate an empty board.
  """
  @spec new() :: list(Cell.t())
  def new() do
    six_point_star()
    |> Enum.map(&%Cell{position: &1})
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

  @doc """
  Return a list of cells from start to finish.
  Returns an empty list if there is no path.
  """
  @spec path(t(), Cell.t(), Cell.t()) :: list(Cell.t())
  def path(_board, start, finish) when start.position == finish.position or start.marble == nil,
    do: []

  def path(board, start, finish) do
    neighbors = Hex.neighbors(start.position)

    non_jump_possible? =
      finish.marble == nil and
        Enum.find(neighbors, fn {_direction, hex} -> hex == finish.position end)

    if non_jump_possible? do
      [start, finish]
    else
      paths =
        jump_move(
          board,
          nil,
          start,
          finish,
          %{start => :done},
          [start]
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

  @spec jump_move(t(), jump_direction(), Cell.t(), Cell.t(), path_guide(), list(Cell.t())) ::
          path_guide()
  defp jump_move(_board, _jump_direction, _start, _finish, came_from, []), do: came_from

  defp jump_move(_board, _jump_direction, _start, finish, came_from, [current | _cells])
       when finish.position == current.position do
    came_from
  end

  defp jump_move(board, jump_direction, start, finish, came_from, [current | cells]) do
    neighboring_cells =
      current
      |> neighbors(jump_direction)
      |> remove_invalid_cells(board)
      |> convert_hex_positions_to_cells(board)
      |> filter_occupied_cells(jump_direction)
      |> remove_visited_cells(came_from)

    jump_direction = get_next_jump_direction(neighboring_cells)

    next_cells =
      neighboring_cells
      |> Enum.map(fn {_direction, cell} -> cell end)
      |> Kernel.++(cells)

    came_from = update_came_from(came_from, current, next_cells)

    jump_move(board, jump_direction, start, finish, came_from, next_cells)
  end

  @spec update_came_from(path_guide(), Cell.t(), list(Cell.t())) :: path_guide()
  defp update_came_from(came_from, current, next_cells) do
    with [next_neighbor | _] <- next_cells do
      Map.put(came_from, next_neighbor, current)
    else
      _ -> came_from
    end
  end

  @spec get_next_jump_direction(list({jump_direction(), Cell.t()})) :: jump_direction()
  defp get_next_jump_direction([]), do: nil
  defp get_next_jump_direction([{jump_direction, _cell} | _]), do: jump_direction

  @spec convert_hex_positions_to_cells(list({jump_direction(), Hex.t()}), t()) ::
          list({jump_direction(), Cell.t()})
  defp convert_hex_positions_to_cells(neighbors, board) do
    Enum.reduce(neighbors, [], fn {direction, position}, acc ->
      cell = Enum.find(board, &(&1.position == position))

      if cell do
        [{direction, cell} | acc]
      else
        acc
      end
    end)
  end

  @spec neighbors(Cell.t(), jump_direction()) :: list({jump_direction(), Hex.t()})
  defp neighbors(cell, nil), do: Hex.neighbors(cell.position)
  defp neighbors(cell, jump_direction), do: [{nil, Hex.neighbor(cell.position, jump_direction)}]

  @spec remove_invalid_cells(list({jump_direction(), Hex.t()}), t()) ::
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

  defp filter_occupied_cells(cells, _jump_direction) do
    Enum.filter(cells, fn {_direction, cell} ->
      cell.marble == nil
    end)
  end
end
