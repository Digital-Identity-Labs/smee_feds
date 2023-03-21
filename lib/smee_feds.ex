defmodule SmeeFeds do
  @moduledoc """
  Documentation for `SmeeFeds`.
  """

  alias SmeeFeds.Federation
  alias SmeeFeds.Data
  alias Smee.Metadata
  alias Smee.Entity
  alias Smee.Source

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

  def publisher(smee_struct, federations \\ federations()) do
    federations
    |> Enum.find(fn federation -> publisher?(federation, smee_struct)  end)
  end

  def publisher?(federation, %Metadata{uri: uri, url: url} = metadata) do
    cond do
      uri == federation.uri -> true
      Enum.any?(Federation.sources(federation), fn s -> s.url == url end) -> true
      true -> false
    end
  end

  def publisher?(federation, %Entity{metadata_uri: uri} = entity) do
    cond do
      uri == federation.uri -> true
      true -> false
    end
  end

  def publisher?(federation, %Source{url: url} = entity) do
    cond do
      Enum.any?(Federation.sources(federation), fn s -> s.url == url end) -> true
      true -> false
    end
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
