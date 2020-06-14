defmodule OT.Text.CompositionTest do
  use ExUnit.Case, async: true

  doctest OT.Text.Composition

  require OT.Fuzzer

  test "can compose many" do
    op_a = [2, "a"]
    op_b = [-1, 2, "b"]
    op_c = [3, "c"]
    operations = [op_a, op_b, op_c]

    {:ok, res} = OT.Text.compose_many(operations)

    res2 =
      Enum.reduce(operations, fn el, acc ->
        {:ok, comp} = OT.Text.compose(acc, el)
        comp
      end)

    assert res == res2
    assert res == [-1, 1, "abc"]
  end
end
