defmodule SmeeFeds.Filter do

  @moduledoc """
  Process a stream of entities to include or exclude entity structs matching the specified criteria.

  These functions are intended to be used with streams but should also work with simple lists too - but using lists to
  process larger metadata files is **strongly discouraged**.

  By default these functions include matching entities and exclude those that do not match, but this an be reversed.
  By default `Smee.Filter.idp/3` will exclude entities that are no IdPs. But by specifying `false` as the third
  parameter the filter will be inverted and exclude entities that have an IdP role.

  """

  alias SmeeFeds.Federation

  @spec eu(enum :: Enumerable.t(), bool :: boolean) :: Enumerable.t()
  def eu(enum, bool \\ true) do
    enum
    |> Enum.filter(
         fn f -> Federation.countries(f)
                 |> Enum.any?(fn c -> c.eu_member == bool end)
         end
       )
  end

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

  #############################################################################

end
