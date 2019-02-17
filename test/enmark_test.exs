defmodule EnmarkTest do
  use ExUnit.Case
  doctest Enmark

  test "greets the world" do
    assert Enmark.hello() == :world
  end
end
