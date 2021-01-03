defmodule Sternhalma.Cell do
  alias __MODULE__
  alias Sternhalma.Hex

  @enforce_keys [:position]
  defstruct [:position, :marble, :target]

  @typedoc """
  Represents a single spot on the board.
  """
  @type t :: %Cell{position: Hex.t(), marble: marble(), target: marble()}

  @type marble :: nil | String.t()

  @doc """
  Puts a marble in the given cell.

  ## Examples

      iex> set_marble(%Sternhalma.Cell{position: Sternhalma.Hex.new({0,0,0})}, "a")
      %Sternhalma.Cell{marble: "a", position: %Sternhalma.Hex{x: 0, y: 0, z: 0}}


  """
  @spec set_marble(t(), marble()) :: t()
  def set_marble(cell, marble), do: %Cell{cell | marble: marble}

  @doc """
  Set which marble is the target in a given cell.
  The target is used to determine if marbles are
  located in their winning positions.

  ## Examples

      iex> set_target(%Sternhalma.Cell{position: Sternhalma.Hex.new({0,0,0})}, "a")
      %Sternhalma.Cell{target: "a", position: %Sternhalma.Hex{x: 0, y: 0, z: 0}}

      iex> set_target(%Sternhalma.Cell{marble: "b", position: Sternhalma.Hex.new({0,0,0})}, "a")
      %Sternhalma.Cell{target: "a", marble: "b", position: %Sternhalma.Hex{x: 0, y: 0, z: 0}}


  """
  @spec set_target(t(), marble()) :: t()
  def set_target(cell, marble), do: %Cell{cell | target: marble}
end
