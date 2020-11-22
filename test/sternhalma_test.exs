defmodule SternhalmaTest do
  use ExUnit.Case
  doctest Sternhalma

  test "greets the world" do
    assert Sternhalma.hello() == :world
  end
end
