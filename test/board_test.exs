defmodule BoardTest do
  use ExUnit.Case
  doctest Sternhalma.Board, import: true

  alias Sternhalma.{Board, Hex, Cell}

  setup_all do
    {:ok,
     board: Board.new(),
     start_cell: %Cell{marble: 'a', position: Hex.from_pixel({10, 1})},
     finish_cell: %Cell{position: Hex.from_pixel({10.866, 2.5})}}
  end

  test "finds path to a neighboring cell", state do
    assert Board.path(state[:board], state[:start_cell], state[:finish_cell]) == [
             state[:start_cell],
             state[:finish_cell]
           ]
  end

  test "does not find path to a distant cell", state do
    finish = %Cell{position: Hex.from_pixel({8.268, 4})}

    assert Board.path(state[:board], state[:start_cell], finish) == []
  end

  test "does not find path to the same cell", state do
    assert Board.path(state[:board], state[:start_cell], state[:start_cell]) == []
  end

  test "does not find path when the starting cell does not have a marble", state do
    start = state[:start_cell] |> Cell.set_marble(nil)
    assert Board.path(state[:board], start, state[:finish_cell]) == []
  end

  describe "pathfinding" do
    defp update_cell(cell = %Cell{position: %Hex{x: 3, z: -6, y: 3}}),
      do: Cell.set_marble(cell, 'a')

    defp update_cell(cell = %Cell{position: %Hex{x: 2, z: -5, y: 3}}),
      do: Cell.set_marble(cell, 'a')

    defp update_cell(cell = %Cell{position: %Hex{x: 2, z: -4, y: 2}}),
      do: Cell.set_marble(cell, 'a')

    defp update_cell(cell), do: cell

    setup do
      board =
        Board.new()
        |> Enum.map(&update_cell(&1))

      {:ok, board: board}
    end

    test "finds path by skipping a marble once", %{board: board} do
      start = %Cell{marble: 'a', position: Hex.from_pixel({10, 1})}
      finish = %Cell{position: Hex.from_pixel({8.268, 4})}

      assert Board.path(board, start, finish) == [
               start,
               %Cell{marble: 'a', position: %Hex{x: 2, z: -5, y: 3}},
               finish
             ]
    end

    test "finds path by skipping a marble twice", %{board: board} do
      start = %Cell{marble: 'a', position: Hex.from_pixel({10, 1})}
      finish = %Cell{position: Hex.from_pixel({11.732, 4})}

      expected_path = [
        start,
        %Cell{marble: 'a', position: Hex.from_pixel({9.134, 2.5})},
        %Cell{position: Hex.from_pixel({8.268, 4})},
        %Cell{marble: 'a', position: Hex.from_pixel({10, 4})},
        finish
      ]

      assert Board.path(board, start, finish) == expected_path
    end
  end
end
