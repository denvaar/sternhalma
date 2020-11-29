defmodule SternhalmaTest do
  use ExUnit.Case, async: true
  doctest Sternhalma

  @game_id "testing"

  setup do
    game_pid = start_supervised!({Sternhalma, @game_id})
    %{game_pid: game_pid}
  end

  test "add a player to a game in with :setup status", %{game_pid: game_pid} do
    assert :sys.get_state(game_pid).status == :setup
    assert {:ok, _game} = Sternhalma.add_player(@game_id, "a")
    assert {:ok, game} = Sternhalma.add_player(@game_id, "b")
    assert length(Enum.filter(game.board, &(&1.marble == "a"))) == 10
    assert length(Enum.filter(game.board, &(&1.marble == "b"))) == 10
  end

  test "add three players then remove two" do
    assert {:ok, _game} = Sternhalma.add_player(@game_id, "a")
    assert {:ok, _game} = Sternhalma.add_player(@game_id, "b")
    assert {:ok, _game} = Sternhalma.add_player(@game_id, "c")
    assert {:ok, _game} = Sternhalma.remove_player(@game_id, "a")
    assert {:ok, game} = Sternhalma.remove_player(@game_id, "b")
    assert length(Enum.filter(game.board, &(&1.marble == "a"))) == 0
    assert length(Enum.filter(game.board, &(&1.marble == "b"))) == 0
    assert length(Enum.filter(game.board, &(&1.marble == "c"))) == 10
  end

  test "set players" do
    assert {:ok, _game} = Sternhalma.add_player(@game_id, "z")
    assert {:ok, game} = Sternhalma.set_players(@game_id, ["a", "b", "c"])
    assert length(Enum.filter(game.board, &(&1.marble == "a"))) == 10
    assert length(Enum.filter(game.board, &(&1.marble == "b"))) == 10
    assert length(Enum.filter(game.board, &(&1.marble == "c"))) == 10
    assert length(Enum.filter(game.board, &(&1.marble == "z"))) == 0
  end

  test "cannot set status to :playing with less than two players", %{game_pid: game_pid} do
    assert :sys.get_state(game_pid).status == :setup
    assert {:ok, _game} = Sternhalma.add_player(@game_id, "a")
    assert {:error, game} = Sternhalma.play_game(@game_id)
    assert game.status == :setup
  end

  test "set status to :playing then to :over", %{game_pid: game_pid} do
    assert :sys.get_state(game_pid).status == :setup
    assert {:ok, _game} = Sternhalma.add_player(@game_id, "a")
    assert {:ok, _game} = Sternhalma.add_player(@game_id, "b")

    assert {:error, _game} = Sternhalma.end_game(@game_id)

    assert {:ok, game} = Sternhalma.play_game(@game_id)
    assert game.status == :playing
    refute game.turn == nil

    assert {:ok, game} = Sternhalma.end_game(@game_id)
    assert game.status == :over
  end

  describe "gameplay" do
    setup %{game_pid: game_pid} do
      {:ok, _game} = Sternhalma.add_player(@game_id, "a")
      {:ok, _game} = Sternhalma.add_player(@game_id, "b")
      {:ok, _game} = Sternhalma.play_game(@game_id)

      %{game_pid: game_pid}
    end

    test "players cannot move when it's not their turn", %{game_pid: game_pid} do
      assert %{turn: "b"} = :sys.get_state(game_pid)

      assert {:error, "invalid start or end position"} =
               Sternhalma.move_marble(@game_id, {12.598, 20.5}, {11.732, 19})
    end

    test "players alternate turns moving marbles", %{game_pid: game_pid} do
      assert %{turn: "b"} = :sys.get_state(game_pid)

      assert {:ok, game} = Sternhalma.move_marble(@game_id, {9.134, 5.5}, {10, 7})
      assert %{turn: "a", last_move: last_move} = game
      assert length(last_move) > 0

      assert {:ok, game} = Sternhalma.move_marble(@game_id, {12.598, 20.5}, {11.732, 19})
      assert %{turn: "b", last_move: last_move} = game
      assert length(last_move) > 0

      assert {:ok, game} = Sternhalma.move_marble(@game_id, {10.866, 5.5}, {9.134, 8.5})
      assert %{turn: "a", last_move: last_move} = game
      assert length(last_move) > 0
    end
  end
end
