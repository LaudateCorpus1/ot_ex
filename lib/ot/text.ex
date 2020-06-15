defmodule OT.Text do
  @moduledoc """
  A [TP1][tp1] operational transformation implementation based heavily on
  [ot-text][ot_text], but modified to be invertable.

  In this OT type, operations are represented as traversals of an entire string,
  with any final retain components implicit. This means that given the text
  "Foz Baz", the operation needed to change it to "Foo Bar Baz" would be
  represented thusly:

  ```elixir
  [2, %{d: "z"}, %{i: "o Bar"}]
  ```

  Notice that the final retain component, `4` (to skip over " Baz") is
  implicit and it not included.

  [tp1]: https://en.wikipedia.org/wiki/Operational_transformation#Convergence_properties
  [ot_text]: https://github.com/ottypes/text/blob/76870df362a1ecb615b15429f1cd6e6b99349542/lib/text.js
  """

  @behaviour OT.Type

  @typedoc "A string that this OT type can operate on"
  @type datum :: String.t()

  @doc """
  Initialize a blank text datum.
  """
  @spec init :: datum
  def init, do: ""

  defdelegate apply(text, op), to: OT.Text.Application
  defdelegate apply!(text, op), to: OT.Text.Application
  defdelegate compose(op_a, op_b), to: OT.Text.Composition
  defdelegate compose_many(ops), to: OT.Text.Composition
  defdelegate transform(op_a, op_b), to: OT.Text.Transformation
  defdelegate transform_index(op, index), to: OT.Text.Transformation

  @doc false
  @spec init_random(non_neg_integer) :: datum
  def init_random(length \\ 64) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> String.slice(0, length)
  end

  def random_op(code) do
    type = [:insert, :retain, :delete] |> Enum.random()

    random = do_random(type)

    retain =
      case type do
        :delete -> String.length(code) + random
        _ -> String.length(code)
      end

    split = :rand.uniform(retain)
    {s, s2} = String.split_at(code, split)

    [String.length(s), do_random(type), String.length(s2)]
  end

  defp do_random(type, length \\ 20)

  defp do_random(:insert, length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end

  defp do_random(:retain, length) do
    :rand.uniform(length)
  end

  defp do_random(:delete, length) do
    -:rand.uniform(length)
  end
end
