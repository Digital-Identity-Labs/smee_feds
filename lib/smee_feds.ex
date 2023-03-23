defmodule SmeeFeds do
  @moduledoc """
  Documentation for `SmeeFeds`.
  """

  alias SmeeFeds.Federation
  alias SmeeFeds.Data
  alias Smee.Metadata
  alias Smee.Entity
  alias Smee.Source

  @spec ids(federations :: list() | nil) :: list(atom())
  def ids() do
    Data.federations()
    |> Map.keys()
  end

  def ids(federations) do
    federations
    |> Enum.map(fn f -> f.id end)
  end

  @spec federations(federations :: list()) :: list(Federation.t())
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

  @spec federations() :: list(Federation.t())
  def federations() do
    Data.federations()
    |> Map.values()
  end

  @spec federation(federation :: atom()| binary()) :: Federation.t() | nil
  def federation(id) do
    get(id)
  end

  @spec get(federation :: atom()| binary()) :: Federation.t() | nil
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

  @spec publisher(smee_struct :: Source.t() | Metadata.t() | Entity.t()) :: Federation.t() | nil
  def publisher(smee_struct, federations \\ federations()) do
    federations
    |> Enum.find(fn federation -> publisher?(federation, smee_struct)  end)
  end

  @spec publisher?(Federation.t(), smee_struct :: Source.t() | Metadata.t() | Entity.t()) :: boolean()
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

  @spec countries(list(Federation.t())) :: list(struct())
  def countries(federations \\ federations()) do
    federations
    |> List.wrap()
    |> Enum.flat_map(fn f -> Map.get(f, :countries, []) end)
    |> Enum.uniq()
    |> Enum.sort()
    |> Enum.map(fn code -> Countries.get(code) end)
  end

  @spec regions(list(Federation.t())) :: list(struct())
  def regions(federations \\ federations()) do
    federations
    |> countries()
    |> Enum.map(fn c -> c.region end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @spec sub_regions(list(Federation.t())) :: list(struct())
  def sub_regions(federations \\ federations()) do
    federations
    |> countries()
    |> Enum.map(fn c -> c.subregion end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @spec super_regions(list(Federation.t())) :: list(struct())
  def super_regions(federations \\ federations()) do
    federations
    |> countries()
    |> Enum.map(fn c -> c.world_region end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  #############################################################################

end
