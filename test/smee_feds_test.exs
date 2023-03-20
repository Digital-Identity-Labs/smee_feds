defmodule SmeeFedsTest do
  use ExUnit.Case
  doctest SmeeFeds

  alias SmeeFeds
  alias SmeeFeds.Federation
  alias Countries.Country

  describe "ids/0" do

    test "returns ids for all federation records as a list" do
      assert 50 < Enum.count(SmeeFeds.ids())
      assert is_list(SmeeFeds.ids())
    end

    test "ids are all atoms" do
      assert Enum.all?(SmeeFeds.ids(), fn k -> is_atom(k) end)
    end

  end

  describe "federations/0" do

    test "returns all active federation records" do
      assert 50 < Enum.count(SmeeFeds.federations())
      assert is_list(SmeeFeds.federations())
    end

    test "federation records are all Federation structs" do
      assert Enum.all?(SmeeFeds.federations(), fn k -> %Federation{} = k end)
    end

  end

  describe "federation/1" do

    test "returns the specified federation record if it exists" do
      assert %Federation{id: :ukamf} = SmeeFeds.federation(:ukamf)
    end

    test "returns nil if specified federation record does not exist" do
      assert is_nil(SmeeFeds.federation(:xxxx))

    end

    test "accepts IDs as either strings or atoms" do
      assert %Federation{id: :ukamf} = SmeeFeds.federation(:ukamf)
      assert %Federation{id: :ukamf} = SmeeFeds.federation("ukamf")
    end

  end

  describe "get/1" do

    test "returns the specified federation record if it exists" do
      assert %Federation{id: :ukamf} = SmeeFeds.get(:ukamf)
    end

    test "returns nil if specified federation record does not exist" do
      assert is_nil(SmeeFeds.get(:xxxx))

    end

    test "accepts IDs as either strings or atoms" do
      assert %Federation{id: :ukamf} = SmeeFeds.get(:ukamf)
      assert %Federation{id: :ukamf} = SmeeFeds.get("ukamf")
    end

  end

  describe "countries/0" do

    test "returns a list of all known countries" do
      assert 10 < Enum.count(SmeeFeds.countries())
      assert is_list(SmeeFeds.countries())
    end

    test "countries are returned as full Country structs" do
      assert Enum.all?(SmeeFeds.countries(), fn v -> %Country{} = v end)
    end

  end

  describe "regions/0" do

    test "returns a list of all known regions" do
      assert ["Africa", "Americas", "Asia", "Europe", "Oceania"] = SmeeFeds.regions()
      assert is_list(SmeeFeds.regions())
    end

    test "regions are returned as strings" do
      assert Enum.all?(SmeeFeds.regions(), fn v -> is_binary(v) end)
    end

  end

  describe "sub_regions/0" do
    test "returns a list of all known sub_regions" do
      assert ["Australia and New Zealand", "Central America", "Central Asia",
        "Eastern Africa", "Eastern Asia", "Eastern Europe", "Northern Africa",
        "Northern America", "Northern Europe", "South America", "South-Eastern Asia",
        "Southern Africa", "Southern Asia", "Southern Europe", "Western Africa",
        "Western Asia", "Western Europe"] = SmeeFeds.sub_regions()
      assert is_list(SmeeFeds.sub_regions())
    end

    test "sub_regions are returned as strings" do
      assert Enum.all?(SmeeFeds.sub_regions(), fn v -> is_binary(v) end)
    end

  end

  describe "super_regions/0" do

    test "returns a list of all known super_regions" do
      assert ["AMER", "APAC", "EMEA"] = SmeeFeds.super_regions()
      assert is_list(SmeeFeds.super_regions())
    end

    test "super_regions are returned as strings" do
      assert Enum.all?(SmeeFeds.super_regions(), fn v -> is_binary(v) end)
    end

  end

end
