defmodule Sternhalma.Cell do
  alias __MODULE__
  alias Sternhalma.Hex

  @enforce_keys [:position]
  defstruct [:position, :marble]

  @type t :: %Cell{position: Hex.t(), marble: marble}
  @type marble :: nil | char()

  def set_marble(cell, marble), do: %Cell{cell | marble: marble}
end
