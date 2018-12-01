defmodule FilixTest do
  use ExUnit.Case
  doctest Filix

  test "greets the world" do
    assert Filix.hello() == :world
  end
end
