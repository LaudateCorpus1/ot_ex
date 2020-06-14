defmodule OT.Text.TransformationTest do
  use ExUnit.Case, async: true
  alias OT.Text.Transformation
  alias OT.Text.Application

  doctest OT.Text.Transformation

  require OT.Fuzzer

  test "it converts existing inserts to b side retains at the end" do
    a = [
      -7,
      -1,
      "pqjGPUs",
      "TGt8P1Me07",
      -1
    ]

    b = [
      "8-g3Q1RbtAxXwAZrfAziIkJjd1PB-fcv8gd0hVy2x",
      9,
      "Z4JMfYcG",
      "Jip",
      # These two need to be converted to retains
      "j0",
      # These two need to be converted to retains
      "U"
    ]

    expected_result = [17, "8-g3Q1RbtAxXwAZrfAziIkJjd1PB-fcv8gd0hVy2xZ4JMfYcGJipj0U"]
    {:ok, _a_prime, b_prime} = OT.Text.Transformation.transform(a, b)

    assert b_prime == expected_result
  end

  test "can transform an operation with 2 different sides" do
    new_op = [1, "ef", 1]
    conc_op = [2, "vc"]

    {:ok, a_prime, _b_prime} = Transformation.transform(new_op, conc_op)
    assert a_prime == [1, "ef", 3]
  end

  test "can transform an operation with 2 different sides and retain inbetween" do
    # source: abcde
    # new_op: aefbcde
    # con_op: abvccdede
    # result: aefbvccdede
    new_op = [1, "ef", 4]
    conc_op = [2, "vc", 3, "de"]

    {:ok, a_prime, _b_prime} = Transformation.transform(new_op, conc_op)
    assert a_prime == [1, "ef", 8]
  end

  test "can transform an operation" do
    new_op = [2, "vc"]
    conc_op = [1, "ef", 1]

    {:ok, a_prime, _b_prime} = Transformation.transform(new_op, conc_op)
    assert a_prime == [4, "vc"]
  end

  test "exhausted A with retain B" do
    # source: abcdef
    # new_op: abacdef
    # con_op: babcdef
    # result: babacdef
    new_op = [2, "a", 4]
    conc_op = ["b", 6]

    {:ok, a_prime, _b_prime} = Transformation.transform(new_op, conc_op)
    assert a_prime == [3, "a", 4]
    assert {:ok, "babacdef"} == Application.apply("babcdef", a_prime)
  end

  test "deletions" do
    # source: abcdef
    # new_op: abacdef
    # con_op: babcdef
    # result: babacdef
    new_op = [2, "a", 4]
    conc_op = [-1, 5]

    {:ok, res, _} = Transformation.transform(new_op, conc_op)
    assert res == [1, "a", 4]
    assert {:ok, "bacdef"} == Application.apply("bcdef", res)
  end

  test "fuzz test" do
    OT.Fuzzer.transformation_fuzz(OT.Text, 1_000)
  end

  @tag :slow_fuzz
  test "slow fuzz test" do
    OT.Fuzzer.transformation_fuzz(OT.Text, 10_000)
  end
end
