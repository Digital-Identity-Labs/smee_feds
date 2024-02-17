defmodule SmeeFeds.Filter do

  @moduledoc """
  Processes a list or stream of federations to include or exclude federation structs matching the specified criteria.

  By default these functions include matching federations and exclude those that do not match, but this an be reversed.
  For example, by default `SmeeFeds.Filter.eu/3` will exclude entities that are not in the EU, but by specifying `false` as the third
  parameter the filter will be inverted and exclude entities that are in the EU.

  """

  alias SmeeFeds.Federation

  @doc """
  Filter a list of stream of federations so that only those in the EU remain.

  The filter is positive by default but can be inverted by specifying `false`
  """
  @spec eu(enum :: Enumerable.t(), bool :: boolean) :: Enumerable.t()
  def eu(enum, bool \\ true) do
    enum
    |> Enum.filter(
         fn f -> Federation.countries(f)
                 |> Enum.any?(fn c -> c.eu_member == bool end)
         end
       )
  end

  @doc """
  Filter a list of stream of federations so that only those in the specified region remain.

  The list of available regions can be seen by calling `SmeeFeds.regions()`

  The filter is positive by default but can be inverted by specifying `false`
  """
  @spec region(enum :: Enumerable.t(), region :: binary(), bool :: boolean) :: Enumerable.t()
  def region(enum, region, bool \\ true)
  def region(enum, region, true) do
    enum
    |> Enum.filter(
         fn f -> Federation.countries(f)
                 |> Enum.any?(fn c -> String.downcase(c.region) == String.downcase(region) end)
         end
       )
  end

  def region(enum, region, false) do
    enum
    |> Enum.filter(
         fn f -> Federation.countries(f)
                 |> Enum.any?(fn c -> String.downcase(c.region) != String.downcase(region) end)
         end
       )
  end

  @doc """
  Filter a list of stream of federations so that only those in the specified sub_region remain.

  The list of available regions can be seen by calling `SmeeFeds.sub_regions()`

  The filter is positive by default but can be inverted by specifying `false`
  """
  @spec sub_region(enum :: Enumerable.t(), sub_region :: binary(), bool :: boolean) :: Enumerable.t()
  def sub_region(enum, sub_region, bool \\ true)
  def sub_region(enum, sub_region, true) do
    enum
    |> Enum.filter(
         fn f -> Federation.countries(f)
                 |> Enum.any?(fn c -> String.downcase(c.subregion) == String.downcase(sub_region) end)
         end
       )
  end

  def sub_region(enum, sub_region, false) do
    enum
    |> Enum.filter(
         fn f -> Federation.countries(f)
                 |> Enum.any?(fn c -> String.downcase(c.subregion) != String.downcase(sub_region) end)
         end
       )
  end

  @doc """
  Filter a list of stream of federations so that only those in the specified super_region remain.

  The list of available regions can be seen by calling `SmeeFeds.super_regions()`

  The filter is positive by default but can be inverted by specifying `false`
  """
  @spec super_region(enum :: Enumerable.t(), super_region :: binary(), bool :: boolean) :: Enumerable.t()
  def super_region(enum, super_region, bool \\ true)
  def super_region(enum, super_region, true) do
    enum
    |> Enum.filter(
         fn f -> Federation.countries(f)
                 |> Enum.any?(fn c -> String.downcase(c.world_region) == String.downcase(super_region) end)
         end
       )
  end

  def super_region(enum, super_region, false) do
    enum
    |> Enum.filter(
         fn f -> Federation.countries(f)
                 |> Enum.any?(fn c -> String.downcase(c.world_region) != String.downcase(super_region) end)
         end
       )
  end

  @doc """
  Filter a list of stream of federations so that only those with an ID of the specified type remain.

  The filter is positive by default but can be inverted by specifying `false`
  """
  @spec id_type(enum :: Enumerable.t(), id_type :: atom(), bool :: boolean) :: Enumerable.t()
  def id_type(enum, id_type,  bool \\ true) do
    enum
    |> Enum.filter(
         fn f -> !is_nil(Federation.id(f, id_type)) == bool end
       )
  end

  #############################################################################

end
