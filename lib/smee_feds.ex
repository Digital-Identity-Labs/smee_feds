defmodule SmeeFeds do
  @moduledoc """
  Documentation for `SmeeFeds`.
  """

  alias SmeeFeds.Federation
  alias SmeeFeds.Data

  def ids() do
    Data.federations()
    |> Map.keys()
  end

  def federations() do
    Data.federations()
    |> Map.values()
  end

  def federation(id) do
    get(id)
  end

  def get(id) when is_binary(id) do
    try do
      String.to_existing_atom(id)
      |> get()
    rescue
      _ -> nil
    end

  end

  def get(id) do
    Data.federations()
    |> Map.get(id)
  end

  def countries() do
    federations()
    |> Enum.flat_map(fn f -> Map.get(f, :countries, []) end)
    |> Enum.uniq()
    |> Enum.sort()
    |> Enum.map(fn code -> Countries.get(code) end)
  end

  def regions() do
    countries()
    |> Enum.map(fn c -> c.region end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  def sub_regions() do
    countries()
    |> Enum.map(fn c -> c.subregion end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  def super_regions() do
    countries()
    |> Enum.map(fn c -> c.world_region end)
    |> Enum.uniq()
    |> Enum.sort()
  end

end
