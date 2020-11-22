defmodule Sternhalma.Cell do
  alias __MODULE__
  alias Sternhalma.Hex

  @enforce_keys [:position]
  defstruct [:position, :marble]

  @typedoc """
  Represents a single spot on the board.
  """
  @type t :: %Cell{position: Hex.t(), marble: marble()}

  @type marble :: nil | char()

  @doc """
  Puts a marble in the given cell.

  ## Examples

      iex> set_marble(%Sternhalma.Cell{position: Sternhalma.Hex.new({0,0,0})}, 'a')
      %Sternhalma.Cell{marble: 'a', position: %Sternhalma.Hex{x: 0, y: 0, z: 0}}


  """
  @spec set_marble(t(), marble()) :: t()
  def set_marble(cell, marble), do: %Cell{cell | marble: marble}
end
