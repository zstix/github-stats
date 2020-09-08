defmodule GithubTest do
  use ExUnit.Case
  doctest Github

  test "greets the world" do
    assert Github.hello() == :world
  end
end
