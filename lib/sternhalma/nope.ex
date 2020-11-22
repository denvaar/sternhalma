defmodule Sternhalma.Nope do
  # @type t :: %Board{}

  def setup() do
    empty()
  end

  def add_marble(board, {row_index, col_index}, m) do
    board
    |> List.update_at(row_index, fn row ->
      row
      |> List.update_at(col_index, fn _ -> m end)
    end)
  end

  def move_marble(board, from, to) do
    with {:ok, board} <- check_move_valid?(board, from, to) do
      board
      |> add_marble(from, 0)
      |> add_marble(to, 1)
    else
      {:error, board} -> board
    end
  end

  def print(board) do
    Enum.reduce(Enum.with_index(board), "", fn {r, i}, accr ->
      row =
        Enum.reduce(r, "", fn cell, acc ->
          acc <>
            if cell == 1 do
              "● "
            else
              "○ "
            end
        end)

      # if rem(i, 2) == 0, do: "", else: " "
      front = ""
      accr <> front <> row <> "\n"
    end)
    |> IO.puts()
  end

  defp check_move_valid?(board, {f_row, f_col}, {t_row, t_col}) do
    cond do
      abs(f_row - t_row) == 1 and abs(f_col - t_col) == 1 ->
        {:ok, board}

      abs(f_row - t_row) == 1 and abs(f_col - t_col) == 0 ->
        {:ok, board}

      abs(f_row - t_row) == 0 and abs(f_col - t_col) == 1 ->
        {:ok, board}

      true ->
        {:error, board}
    end
  end

  defp backtrack(_paths, nil, _path), do: []
  defp backtrack(_paths, :done, path), do: path

  defp backtrack(paths, to, path) do
    current = Map.get(paths, to)
    backtrack(paths, current, [to | path])
  end

  def path(board, from, to) do
    paths =
      path_exists_helper(
        board,
        from,
        to,
        %{from => :done},
        [from]
      )

    backtrack(paths, to, [])
  end

  defp path_exists_helper(_board, _from, _to, came_from, []), do: came_from

  defp path_exists_helper(_board, _from, to, came_from, [current | _cells]) when to == current do
    came_from
  end

  defp path_exists_helper(board, from, to, came_from, [current | cells]) do
    nexts =
      neighbors(current)
      |> filter_invalid_cells(board)
      |> filter_visited_cells(came_from)
      |> filter_occupied_cells(board)

    came_from =
      nexts
      |> Enum.reduce(came_from, fn next, acc ->
        Map.put(acc, next, current)
      end)

    path_exists_helper(board, from, to, came_from, cells ++ nexts)
  end

  defp neighbors(current) do
    [
      neighbor(current, :up_left),
      neighbor(current, :up_right),
      neighbor(current, :up),
      neighbor(current, :left),
      neighbor(current, :right),
      neighbor(current, :down_left),
      neighbor(current, :down_right),
      neighbor(current, :down)
    ]
  end

  defp filter_visited_cells(neighbors, came_from) do
    neighbors
    |> Enum.reject(fn n -> Map.get(came_from, n) end)
  end

  defp filter_occupied_cells(neighbors, board) do
    neighbors
    |> Enum.filter(fn {row, col} ->
      r = Enum.at(board, row)
      Enum.at(r, col) == 0
    end)
  end

  defp filter_invalid_cells(neighbors, board) do
    neighbors
    |> Enum.filter(fn {row, col} ->
      r = Enum.at(board, row)
      row >= 0 and col >= 0 and !!r and Enum.at(r, col)
    end)
  end

  defp neighbor({row, col}, :up_left), do: {row - 1, col - 1}
  defp neighbor({row, col}, :up_right), do: {row - 1, col + 1}
  defp neighbor({row, col}, :up), do: {row - 1, col}
  defp neighbor({row, col}, :left), do: {row, col - 1}
  defp neighbor({row, col}, :right), do: {row, col + 1}
  defp neighbor({row, col}, :down_left), do: {row + 1, col - 1}
  defp neighbor({row, col}, :down_right), do: {row + 1, col + 1}
  defp neighbor({row, col}, :down), do: {row + 1, col}

  defp empty() do
    for _ <- 0..16 do
      for _ <- 0..24, do: 0
    end
  end
end
