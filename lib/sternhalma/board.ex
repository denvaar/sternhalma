defmodule Sternhalma.Board do
  alias Sternhalma.{Hex, Cell}

  def new() do
    six_point_star()
    |> Enum.map(&%Cell{position: &1})
  end

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

  defp make_row({x, z, y}, length) do
    [
      Enum.to_list(x..(length + x - 1)),
      List.duplicate(z, length),
      Enum.to_list(y..(y - (length - 1)))
    ]
    |> Enum.zip()
    |> Enum.map(&Hex.new(&1))
  end

  def path(board, start, finish) do
    paths =
      path_exists_helper(
        board,
        start,
        finish,
        %{start => :done},
        [start]
      )

    IO.inspect(paths)
    backtrack(paths, finish, [])
  end

  defp backtrack(_paths, nil, _path), do: []
  defp backtrack(_paths, :done, path), do: path

  defp backtrack(paths, finish, path) do
    current = Map.get(paths, finish)
    backtrack(paths, current, [finish | path])
  end

  defp path_exists_helper(_board, _start, _finish, came_from, []), do: came_from

  defp path_exists_helper(_board, _start, finish, came_from, [current | _cells])
       when finish.position == current.position do
    came_from
  end

  defp path_exists_helper(board, start, finish, came_from, [current | cells]) do
    nexts =
      Hex.neighbors(current.position)
      |> filter_invalid_cells(board)
      |> Enum.map(fn hex ->
        Enum.find(board, fn cell ->
          cell.position == hex
        end)
      end)
      |> filter_visited_cells(came_from)
      |> filter_occupied_cells()

    came_from =
      nexts
      |> Enum.reduce(came_from, fn next, acc ->
        Map.put(acc, next, current)
      end)

    path_exists_helper(board, start, finish, came_from, cells ++ nexts)
  end

  defp filter_invalid_cells(neighbors, board) do
    neighbors
    |> Enum.filter(fn neighbor ->
      Enum.any?(board, fn cell -> neighbor == cell.position end)
    end)
  end

  defp filter_visited_cells(cells, came_from) do
    cells
    |> Enum.reject(fn cell -> Map.get(came_from, cell) end)
  end

  defp filter_occupied_cells(cells) do
    Enum.filter(cells, &(&1.marble == nil))
  end
end
