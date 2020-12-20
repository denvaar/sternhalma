defmodule SternhalmaTest do
  use ExUnit.Case, async: true
  doctest Sternhalma, import: true

  alias Sternhalma.{Board, Cell, Hex}

  defp setup_board(occupied_locations) do
    Enum.map(Board.empty(), fn cell ->
      if Enum.any?(occupied_locations, fn point ->
           cell.position == Hex.from_pixel(point)
         end) do
        Cell.set_marble(cell, 'a')
      else
        cell
      end
    end)
  end

  test "move a marble" do
    from = %Cell{marble: "a", position: Hex.from_pixel({10, 1})}
    to = %Cell{position: Hex.from_pixel({8.268, 4})}
    board = setup_board([{10, 1}])

    board = Sternhalma.move_marble(board, "a", from, to)

    assert {:ok, %Cell{marble: nil}} = Board.get_board_cell(board, {10, 1})
    assert {:ok, %Cell{marble: "a"}} = Board.get_board_cell(board, {8.268, 4})
  end

  test "moving a marble does not change the board if invalid cells are used" do
    from = %Cell{marble: "a", position: Hex.from_pixel({100, 15})}
    to = %Cell{position: Hex.from_pixel({1_919_191, 42222})}
    board = setup_board([{10, 1}])

    board = Sternhalma.move_marble(board, "a", from, to)

    assert board == board
  end

  test "setup marbles adds groups of marbles in correct places" do
    board = Sternhalma.empty_board()

    # TODO: test which marbles are in which triangles

    assert {:ok, board} = Sternhalma.setup_marbles(board, "red")
    assert {:ok, board} = Sternhalma.setup_marbles(board, "green")
    assert {:ok, board} = Sternhalma.setup_marbles(board, "blue")
    assert {:ok, board} = Sternhalma.setup_marbles(board, "black")
    assert {:ok, board} = Sternhalma.setup_marbles(board, "yellow")
    assert {:ok, board} = Sternhalma.setup_marbles(board, "white")
    assert {:error, :board_full} = Sternhalma.setup_marbles(board, "purple")
  end
end
