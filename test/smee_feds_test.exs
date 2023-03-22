defmodule SmeeFedsTest do
  use ExUnit.Case
  doctest SmeeFeds

  alias SmeeFeds
  alias SmeeFeds.Federation
  alias Countries.Country
  alias Smee.Source
  alias Smee.Metadata
  alias Smee.Entity


  describe "ids/0" do

    test "returns ids for all federation records as a list" do
      assert 50 < Enum.count(SmeeFeds.ids())
      assert is_list(SmeeFeds.ids())
    end

    test "ids are all atoms" do
      assert Enum.all?(SmeeFeds.ids(), fn k -> is_atom(k) end)
    end

  end

  describe "ids/1" do

    test "returns ids for all federation records as a list" do
      assert 2 = Enum.count(SmeeFeds.ids(SmeeFeds.federations([:ukamf, :incommon])))
      assert is_list(SmeeFeds.ids(SmeeFeds.federations()))
    end

    test "ids are all atoms" do
      assert Enum.all?(SmeeFeds.ids(SmeeFeds.federations()), fn k -> is_atom(k) end)
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

  describe "federations/1" do

    test "returns all federation records with matching IDs when passed a list of ids" do
      assert 2 = Enum.count(SmeeFeds.federations([:ukamf, :incommon, :nothing_matches]))
      assert is_list(SmeeFeds.federations([:ukamf, :incommon]))
    end

    test "passes through federation structs unchanged" do
      assert Enum.all?(SmeeFeds.federations(SmeeFeds.federations()), fn k -> %Federation{} = k end)
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

  describe "publisher?/2" do

    test "returns true if the provided federation definitely published the metadata provided" do
      metadata = Source.new("http://metadata.ukfederation.org.uk/ukfederation-metadata.xml")
                 |> Smee.fetch!()
      ukamf = SmeeFeds.get("ukamf")
      assert SmeeFeds.publisher?(ukamf, metadata)
    end

    test "returns true if the provided federation definitely published the entity provided" do
      entity = Source.new("http://metadata.ukfederation.org.uk/ukfederation-metadata.xml")
               |> Smee.fetch!()
               |> Metadata.random_entity()
      ukamf = SmeeFeds.get("ukamf")
      assert SmeeFeds.publisher?(ukamf, entity)
    end

    test "returns true if the provided federation definitely published the source provided" do
      source = Source.new("http://metadata.ukfederation.org.uk/ukfederation-metadata.xml")
      ukamf = SmeeFeds.get("ukamf")
      assert SmeeFeds.publisher?(ukamf, source)
    end

    test "returns false if no matching federation can be found" do
      source = Source.new("http://metadata.example.org.uk/example-metadata.xml")
      ukamf = SmeeFeds.get("ukamf")
      refute SmeeFeds.publisher?(ukamf, source)
    end

  end

  describe "publisher/2" do

    test "returns the first federation (from the default collection) that could have provided the supplied metadata or entity" do

      source = Source.new("http://metadata.ukfederation.org.uk/ukfederation-metadata.xml")

      metadata = source
                 |> Smee.fetch!()

      entity = metadata
               |> Metadata.random_entity()

      assert %Federation{id: :ukamf} = SmeeFeds.publisher(metadata)
      assert %Federation{id: :ukamf} = SmeeFeds.publisher(entity)
      assert %Federation{id: :ukamf} = SmeeFeds.publisher(source)

    end

    test "returns the first federation (from the passed collection) that could have provided the supplied metadata or entity" do

      federations = SmeeFeds.federations([:ukamf, :incommon])

      source = Source.new("http://metadata.ukfederation.org.uk/ukfederation-metadata.xml")

      metadata = source
                 |> Smee.fetch!()

      entity = metadata
               |> Metadata.random_entity()

      assert %Federation{id: :ukamf} = SmeeFeds.publisher(metadata, federations)
      assert %Federation{id: :ukamf} = SmeeFeds.publisher(entity, federations)
      assert %Federation{id: :ukamf} = SmeeFeds.publisher(source, federations)

    end

    test "returns nil if no publisher can be found" do
      federations = SmeeFeds.federations([:incommon, :wayf])

      source = Source.new("http://metadata.ukfederation.org.uk/ukfederation-metadata.xml")

      metadata = source
                 |> Smee.fetch!()

      entity = metadata
               |> Metadata.random_entity()

      assert nil == SmeeFeds.publisher(metadata, federations)
      assert nil == SmeeFeds.publisher(entity, federations)
      assert nil == SmeeFeds.publisher(source, federations)

    end

  end

  describe "countries/1" do

    test "returns a list of all known countries present in default federations list" do
      assert 10 < Enum.count(SmeeFeds.countries())
      assert is_list(SmeeFeds.countries())
    end

    test "returns a list of all known countries present in the provided federations list" do
      mini_feds = SmeeFeds.federations([:ukamf, :incommon])
      assert 2 = Enum.count(SmeeFeds.countries(mini_feds))
      assert is_list(SmeeFeds.countries(mini_feds))
    end

    test "countries are returned as full Country structs" do
      assert Enum.all?(SmeeFeds.countries(), fn v -> %Country{} = v end)
    end

  end

  describe "regions/1" do

    test "returns a list of all known regions present in default federations list" do
      assert ["Africa", "Americas", "Asia", "Europe", "Oceania"] = SmeeFeds.regions()
      assert is_list(SmeeFeds.regions())
    end

    test "returns a list of all known regions present in the provided federations list" do
      mini_feds = SmeeFeds.federations([:ukamf, :incommon])
      assert ["Americas", "Europe"] = SmeeFeds.regions(mini_feds)
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

    test "returns a list of all known sub_regions present in provided federations list" do
      mini_feds = SmeeFeds.federations([:ukamf, :incommon])
      assert ["Northern America", "Northern Europe"] = SmeeFeds.sub_regions(mini_feds)
      assert is_list(SmeeFeds.sub_regions(mini_feds))
    end

    test "sub_regions are returned as strings" do
      assert Enum.all?(SmeeFeds.sub_regions(), fn v -> is_binary(v) end)
    end

  end

  describe "super_regions/1" do

    test "returns a list of all known super_regions present in default federations list" do
      assert ["AMER", "APAC", "EMEA"] = SmeeFeds.super_regions()
      assert is_list(SmeeFeds.super_regions())
    end

    test "returns a list of all known super_regions present in provided federations list" do
      mini_feds = SmeeFeds.federations([:ukamf, :incommon])
      assert ["AMER", "EMEA"] = SmeeFeds.super_regions(mini_feds)
      assert is_list(SmeeFeds.super_regions(mini_feds))
    end

    test "super_regions are returned as strings" do
      assert Enum.all?(SmeeFeds.super_regions(), fn v -> is_binary(v) end)
    end

  end

end
