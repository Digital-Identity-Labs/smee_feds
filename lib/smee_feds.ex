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

  def ids(federations \\ federations()) do
    federations
    |> Enum.map(fn f -> f.id end)
  end

  def federations(federations) when is_list(federations) do
    federations
#    |> Enum.filter(fn f -> %Federation{} = f end)
    |> Enum.map(
         fn
           %Federation{} = f -> f
           id -> get(id)
         end
       )
    |> Enum.reject(fn v -> is_nil(v) end)
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

  def countries(federations \\ federations()) do
    federations
    |> List.wrap()
    |> Enum.flat_map(fn f -> Map.get(f, :countries, []) end)
    |> Enum.uniq()
    |> Enum.sort()
    |> Enum.map(fn code -> Countries.get(code) end)
  end

  def regions(federations \\ federations()) do
    federations
    |> countries()
    |> Enum.map(fn c -> c.region end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  def sub_regions(federations \\ federations()) do
    federations
    |> countries()
    |> Enum.map(fn c -> c.subregion end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  def super_regions(federations \\ federations()) do
    federations
    |> countries()
    |> Enum.map(fn c -> c.world_region end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  #############################################################################


end
