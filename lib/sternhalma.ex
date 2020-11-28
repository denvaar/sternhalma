defmodule Sternhalma do
  @moduledoc """
  """

  use GenServer

  alias Sternhalma.{Board, Cell, Pathfinding}

  @type game_status :: :setup | :playing | :over

  @type game_state :: %{
          game_id: binary(),
          board: Board.t(),
          turn: nil | char(),
          status: game_status(),
          players: list(char())
        }

  def start_link(game_id) do
    GenServer.start_link(__MODULE__, game_id, name: game_id)
  end

  def add_player(game_id, player_name) do
    GenServer.call(game_id, {:add_player, player_name})
  end

  def play_game(game_id) do
    GenServer.call(game_id, {:set_status, :playing})
  end

  def end_game(game_id) do
    GenServer.call(game_id, {:set_status, :over})
  end

  def move_marble(game_id, start_position, end_position) do
    GenServer.call(game_id, {:find_path, start_position, end_position})
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
      players: []
    }

    {:ok, initial_state}
  end

  @impl true
  def handle_call({:add_player, player_name}, _from, state) do
    number_of_existing_players = length(state.players)

    new_state = %{
      state
      | players: [player_name | state.players],
        board:
          Board.setup_triangle(
            state.board,
            position_opponent(number_of_existing_players),
            player_name
          )
    }

    {:reply, {:ok, new_state}, new_state}
  end

  def handle_call({:find_path, start_position, end_position}, _from, state) do
    with {:ok, start_cell} <- Board.get_board_cell(start_position),
         {:ok, end_cell} <- Board.get_board_cell(end_position) do
      {result, path} = find_path(state.board, start_position, end_position)
      # TODO: update position
      {:reply, {result, path}, state}
    else
      {:reply, {:error, []}, state}
    end
  end

  def handle_call({:set_status, status}, _from, state) do
    {result, new_state} =
      state
      |> change_game_status(status)
      |> perform_side_effects(status)

    {:reply, {result, new_state}, new_state}
  end

  @spec change_game_status(game_state(), game_status()) :: {:ok | :error, game_state()}
  defp change_game_status(game_state, :playing)
       when game_state.players > 1 and game_state.status == :setup,
       do: {:ok, %{game_state | status: :playing}}

  defp change_game_status(game_state, :over) when game_state.status == :playing,
    do: {:ok, %{game_state | status: :over}}

  defp change_game_status(game_state, _), do: {:error, game_state}

  @spec perform_side_effects({:ok | :error, game_state()}, game_status()) ::
          {:ok | :error, game_state()}
  defp perform_side_effects({:ok, game_state}, :playing) do
    {:ok, %{game_state | turn: List.first(game_state.players)}}
  end

  defp perform_side_effects({:error, game_state}, _), do: {:error, game_state}

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
end
