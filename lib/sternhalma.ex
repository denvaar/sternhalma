defmodule Sternhalma do
  @moduledoc """
  """

  use GenServer

  alias Sternhalma.{Board, Cell, Pathfinding}

  @type game_status :: :setup | :playing | :over

  @type game_state :: %{
          game_id: binary(),
          board: Board.t(),
          turn: nil | String.t(),
          last_move: list(Cell.t()),
          status: game_status(),
          players: list(String.t())
        }

  def start_link(game_id) do
    name = via_tuple(game_id)
    GenServer.start_link(__MODULE__, game_id, name: name)
  end

  def add_player(game_id, player_name) do
    GenServer.call(via_tuple(game_id), {:add_player, player_name})
  end

  def remove_player(game_id, player_name) do
    GenServer.call(via_tuple(game_id), {:remove_player, player_name})
  end

  def set_players(game_id, player_names) do
    GenServer.call(via_tuple(game_id), {:set_players, player_names})
  end

  def play_game(game_id) do
    GenServer.call(via_tuple(game_id), {:set_status, :playing})
  end

  def end_game(game_id) do
    GenServer.call(via_tuple(game_id), {:set_status, :over})
  end

  def move_marble(game_id, start_position, end_position) do
    GenServer.call(via_tuple(game_id), {:find_path, start_position, end_position})
  end

  #
  #  |             |
  # \/ Server API \/

  @impl true
  def init(game_id) do
    initial_state = %{
      game_id: game_id,
      board: Board.empty(),
      status: :setup,
      turn: nil,
      last_move: [],
      players: []
    }

    {:ok, initial_state}
  end

  @impl true
  def handle_call({:add_player, player_name}, _from, state) do
    new_state = add_player_impl(state, player_name)

    {:reply, {:ok, new_state}, new_state}
  end

  def handle_call({:remove_player, player_name}, _from, state) do
    game_state = %{
      state
      | players: [],
        board: Board.empty()
    }

    # reset the game board and players to empty,
    # then re-add new players (except the one to be removed)
    new_state =
      state.players
      |> Enum.filter(&(&1 != player_name))
      |> Enum.reduce(game_state, &add_player_impl(&2, &1))

    {:reply, {:ok, new_state}, new_state}
  end

  def handle_call({:set_players, player_names}, _from, state) do
    game_state = %{
      state
      | players: [],
        board: Board.empty()
    }

    new_state =
      player_names
      |> Enum.reduce(game_state, &add_player_impl(&2, &1))

    {:reply, {:ok, new_state}, new_state}
  end

  def handle_call({:find_path, start_position, end_position}, _from, state) do
    %{turn: turn} = state

    # TODO refactor this function
    with(
      {:ok, %Cell{marble: ^turn} = start_cell} <-
        Board.get_board_cell(state.board, start_position),
      {:ok, end_cell} <- Board.get_board_cell(state.board, end_position)
    ) do
      {result, path} = find_path(state.board, start_cell, end_cell)

      board =
        state.board
        |> Enum.map(fn board_cell ->
          cond do
            board_cell.position == start_cell.position ->
              Cell.set_marble(board_cell, nil)

            board_cell.position == end_cell.position ->
              Cell.set_marble(board_cell, state.turn)

            true ->
              board_cell
          end
        end)

      new_state = %{
        state
        | board: board,
          last_move: path,
          turn: next_turn(state.players, state.turn)
      }

      {:reply, {result, new_state}, new_state}
    else
      _ ->
        {:reply, {:error, "invalid start or end position"}, state}
    end
  end

  def handle_call({:set_status, status}, _from, state) do
    {result, new_state} =
      state
      |> change_game_status(status)
      |> perform_side_effects(status)

    {:reply, {result, new_state}, new_state}
  end

  # TODO consider moving these private functions to some other module

  @spec change_game_status(game_state(), game_status()) :: {:ok | :error, game_state()}
  defp change_game_status(game_state, :playing)
       when length(game_state.players) > 1 and game_state.status == :setup,
       do: {:ok, %{game_state | status: :playing}}

  defp change_game_status(game_state, :over) when game_state.status == :playing,
    do: {:ok, %{game_state | status: :over}}

  defp change_game_status(game_state, _), do: {:error, game_state}

  @spec perform_side_effects({:ok | :error, game_state()}, game_status()) ::
          {:ok | :error, game_state()}
  defp perform_side_effects({:ok, game_state}, :playing) do
    {:ok, %{game_state | turn: List.first(game_state.players)}}
  end

  defp perform_side_effects({:ok, game_state}, _), do: {:ok, game_state}
  defp perform_side_effects({:error, game_state}, _), do: {:error, game_state}

  @spec add_player_impl(game_state(), String.t()) :: game_state()
  defp add_player_impl(game_state, player_name) do
    number_of_existing_players = length(game_state.players)

    %{
      game_state
      | players: [player_name | game_state.players],
        board:
          Board.setup_triangle(
            game_state.board,
            position_opponent(number_of_existing_players),
            player_name
          )
    }
  end

  @spec position_opponent(0..5) :: Board.home_triangle()
  defp position_opponent(0), do: :top
  defp position_opponent(1), do: :bottom
  defp position_opponent(2), do: :top_left
  defp position_opponent(3), do: :bottom_right
  defp position_opponent(4), do: :top_right
  defp position_opponent(5), do: :bottom_left

  @spec find_path(Board.t(), Cell.t(), Cell.t()) :: {:ok | :error, list(Cell.t())}
  defp find_path(board, start_cell, end_cell) do
    result_path = Pathfinding.path(board, start_cell, end_cell)
    {pathfinding_status(result_path), result_path}
  end

  @spec pathfinding_status(list(Cell.t())) :: :ok | :error
  defp pathfinding_status([]), do: :error
  defp pathfinding_status(_path), do: :ok

  @spec next_turn(list(String.t()), String.t()) :: String.t()
  defp next_turn(players, turn) do
    next_player_index =
      case Enum.find_index(players, &(&1 == turn)) do
        nil ->
          0

        current_player_index ->
          rem(current_player_index + 1, length(players))
      end

    Enum.at(players, next_player_index)
  end

  defp via_tuple(game_id) do
    {:via, Registry, {:sternhalma_registry, game_id}}
  end
end
