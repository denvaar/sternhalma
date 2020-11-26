defmodule BoardTest do
  use ExUnit.Case
  doctest Sternhalma.Board, import: true

  alias Sternhalma.{Board, Hex, Cell}

  defp setup_board(occupied_locations) do
    Enum.map(Board.new(), fn cell ->
      if Enum.any?(occupied_locations, fn point ->
           cell.position == Hex.from_pixel(point)
         end) do
        Cell.set_marble(cell, 'a')
      else
        cell
      end
    end)
  end

  test "finds path to a neighboring cell" do
    #
    # o = empty cell
    # x = cell with marble
    # s = start
    # f = finish
    #             o
    #            o o
    #           o o o
    #          o o o o
    # o o o o o o o o o o o o o
    #  o o o o o o o o o o o o
    #   o o o o o o o o o o o
    #    o o o o o o o o o o
    #     o o o o o o o o o
    #    o o o o o o o o o o
    #   o o o o o o o o o o o
    #  o o o o o o o o o o o o
    # o o o o o o o o o o o o o
    #          o s o o
    #           o f o
    #            o o
    #             o
    #

    start = %Cell{marble: 'a', position: Hex.from_pixel({9.134, 5.5})}
    finish = %Cell{position: Hex.from_pixel({10, 4})}
    board = setup_board([])

    assert Board.path(board, start, finish) == [
             start,
             finish
           ]
  end

  test "does not find path to a distant cell" do
    start = %Cell{marble: 'a', position: Hex.from_pixel({10, 1})}
    finish = %Cell{position: Hex.from_pixel({8.268, 4})}
    board = setup_board([{10, 1}])

    assert Board.path(board, start, finish) == []
  end

  test "does not find path to the same cell" do
    start = %Cell{marble: 'a', position: Hex.from_pixel({9.134, 5.5})}
    board = setup_board([{9.134, 5.5}])

    assert Board.path(board, start, start) == []
  end

  test "does not find path when the starting cell does not have a marble" do
    start = %Cell{marble: nil, position: Hex.from_pixel({9.134, 5.5})}
    finish = %Cell{position: Hex.from_pixel({10, 4})}
    board = setup_board([])

    assert Board.path(board, start, finish) == []
  end

  test "finds a path by jumping in a straight line", _state do
    #
    # o = empty cell
    # x = cell with marble
    # s = start
    # f = finish
    #             o
    #            o o
    #           o o o
    #          o o o o
    # o o o o o o o o o o o o o
    #  o o o o o o o o o o o o
    #   o o o o o o o o o o o
    #    o o o o o o o o o o
    #     o o o o o o o o o
    #    o o o o o o o o o o
    #   o o f o o o o o o o o
    #  o o o x o o o o o o o o
    # o o o o o o o o o o o o o
    #          x o o o
    #           o o o
    #            x o
    #             s
    #

    start = %Cell{marble: 'a', position: Hex.from_pixel({10, 1})}
    finish = %Cell{position: Hex.from_pixel({4.804, 10})}
    board = setup_board([{9.134, 2.5}, {7.402, 5.5}, {5.67, 8.5}])

    assert Board.path(board, start, finish) == [
             start,
             %Cell{marble: 'a', position: Hex.from_pixel({9.134, 2.5})},
             %Cell{position: Hex.from_pixel({8.268, 4})},
             %Cell{marble: 'a', position: Hex.from_pixel({7.402, 5.5})},
             %Cell{position: Hex.from_pixel({6.536, 7})},
             %Cell{marble: 'a', position: Hex.from_pixel({5.67, 8.5})},
             finish
           ]
  end

  test "finds a path by jumping and changing directions", _state do
    #
    # o = empty cell
    # x = cell with marble
    # s = start
    # f = finish
    #             o
    #            o o
    #           o o o
    #          o o o o
    # o o o o o o o o o o o o o
    #  o o o o o o o o o o o o
    #   o o o o o o o o o o o
    #    o o o o o o o o o o
    #     o o o o o o o o o
    #    o o o o o o o o o o
    #   o o o o o o o o o o o
    #  o o o o o o o o o o o o
    # o o o o o o f x o o o o o
    #          o o o x
    #           o x o
    #            x o
    #             s
    #

    start = %Cell{marble: 'a', position: Hex.from_pixel({10, 1})}
    finish = %Cell{position: Hex.from_pixel({10, 7})}
    board = setup_board([{9.134, 2.5}, {10, 4}, {12.598, 5.5}, {11.732, 7}])

    assert Board.path(board, start, finish) == [
             start,
             %Cell{marble: 'a', position: Hex.from_pixel({9.134, 2.5})},
             %Cell{position: Hex.from_pixel({8.268, 4})},
             %Cell{marble: 'a', position: Hex.from_pixel({10, 4})},
             %Cell{position: Hex.from_pixel({11.732, 4})},
             %Cell{marble: 'a', position: Hex.from_pixel({12.598, 5.5})},
             %Cell{position: Hex.from_pixel({13.464, 7})},
             %Cell{marble: 'a', position: Hex.from_pixel({11.732, 7})},
             finish
           ]
  end

  test "does not find path when jump not possible", _state do
    #
    # o = empty cell
    # x = cell with marble
    # s = start
    # f = finish
    #             o
    #            o o
    #           o o o
    #          o o o o
    # o o o o o o o o o o o o o
    #  o o o o o o o o o o o o
    #   o o o o o o o o o o o
    #    o o o o o o o o o o
    #     o o o o o o o o o
    #    o o o o o o o o o o
    #   o o o o o o o o o o o
    #  o o o o o o o o o o o o
    # o o o o o o o o o o o o o
    #          o o o o
    #           o s o
    #            x x
    #             f
    #

    start = %Cell{marble: 'a', position: Hex.from_pixel({10, 4})}
    finish = %Cell{position: Hex.from_pixel({10, 1})}
    board = setup_board([{10, 4}, {9.134, 2.5}, {10.866, 2.5}])

    assert Board.path(board, start, finish) == []
  end

  test "does not find path when finishing cell is occupied", _state do
    #
    # o = empty cell
    # x = cell with marble
    # s = start
    # f = finish
    #             o
    #            o o
    #           o o o
    #          o o o o
    # o o o o o o o o o o o o o
    #  o o o o o o o o o o o o
    #   o o o o o o o o o o o
    #    o o o o o o o o o o
    #     o o o o o o o o o
    #    o o o o o o o o o o
    #   o o o o o o o o o o o
    #  o o o o o o o o o o o o
    # o o o o o f o o o o o o o
    #          o x o o
    #           o s o
    #            o o
    #             o
    #

    start = %Cell{marble: 'a', position: Hex.from_pixel({10, 4})}
    finish = %Cell{position: Hex.from_pixel({8.268, 7})}
    board = setup_board([{9.134, 5.5}, {8.268, 7}])

    assert Board.path(board, start, finish) == []
  end
end
