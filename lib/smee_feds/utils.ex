defmodule SmeeFeds.Utils do
  @moduledoc false

  @spec to_safe_atoms(input :: atom() | binary() | list()) :: list(atom())
  def to_safe_atoms(input) do
    input
    |> List.wrap()
    |> Enum.map(fn x -> to_safe_atom(x) end)
    |> Enum.reject(fn x -> is_nil(x) end)
  end

  @spec to_safe_atom(input :: atom() | binary()) :: atom() | nil
  def to_safe_atom(input) when is_binary(input) do
    try do
      input
      |> String.trim()
      |> String.downcase()
      |> String.to_existing_atom()
    rescue
      _ -> nil
    end
  end

  def to_safe_atom(input) when is_atom(input) do
    input
  end

end
