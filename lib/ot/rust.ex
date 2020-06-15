defmodule Elixir.Rust.OT do
  use Rustler, otp_app: :ot_ex, crate: "rust_ot"

  # When your NIF is loaded, it will override this function.
  def apply(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
  def transform(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
  def transform_index(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
  def compose(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
  def compose_many(_ops), do: :erlang.nif_error(:nif_not_loaded)
end
