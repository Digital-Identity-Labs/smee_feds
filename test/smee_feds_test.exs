defmodule SmeeFedsTest do
  use ExUnit.Case
  doctest SmeeFeds

  alias SmeeFeds
  alias SmeeFeds.Federation
  alias Countries.Country
  alias Smee.Source
  alias Smee.Metadata

  @federations_list SmeeFeds.federations()

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

  describe "get/2" do

    test "returns the specified federation record if it exists" do
      assert %Federation{id: :ukamf} = SmeeFeds.get(@federations_list, :ukamf)
    end

    test "returns nil if specified federation record does not exist" do
      assert is_nil(SmeeFeds.get(@federations_list, :xxxx))

    end

    test "accepts IDs as either strings or atoms" do
      assert %Federation{id: :ukamf} = SmeeFeds.get(@federations_list, :ukamf)
      assert %Federation{id: :ukamf} = SmeeFeds.get(@federations_list, "ukamf")
    end

  end

  describe "take/2" do

    test "returns all federation records with matching IDs when passed a list of ids" do
      assert 2 = Enum.count(SmeeFeds.take(@federations_list, [:ukamf, :incommon, :nothing_matches]))
      assert is_list(SmeeFeds.take(@federations_list, [:ukamf, :incommon, :nothing_matches]))
    end

  end

  describe "publisher?/2" do

    @tag timeout: 180_000
    test "returns true if the provided federation definitely published the metadata provided" do
      metadata = Source.new("http://metadata.ukfederation.org.uk/ukfederation-metadata.xml")
                 |> Smee.fetch!()
      ukamf = SmeeFeds.federation("ukamf")
      assert SmeeFeds.publisher?(ukamf, metadata)
    end

    @tag timeout: 180_000
    test "returns true if the provided federation definitely published the entity provided" do
      entity = Source.new("http://metadata.ukfederation.org.uk/ukfederation-metadata.xml")
               |> Smee.fetch!()
               |> Metadata.random_entity()
      ukamf = SmeeFeds.federation("ukamf")
      assert SmeeFeds.publisher?(ukamf, entity)
    end

    @tag timeout: 180_000
    test "returns true if the provided federation definitely published the source provided" do
      source = Source.new("http://metadata.ukfederation.org.uk/ukfederation-metadata.xml")
      ukamf = SmeeFeds.federation("ukamf")
      assert SmeeFeds.publisher?(ukamf, source)
    end

    @tag timeout: 180_000
    test "returns false if no matching federation can be found" do
      source = Source.new("http://metadata.example.org.uk/example-metadata.xml")
      ukamf = SmeeFeds.federation("ukamf")
      refute SmeeFeds.publisher?(ukamf, source)
    end

  end

  describe "publisher/2" do

    @tag timeout: 180_000
    test "returns the first federation (from the default collection) that could have provided the supplied metadata or entity" do

      source = Source.new("http://metadata.ukfederation.org.uk/ukfederation-metadata.xml")

      metadata = source
                 |> Smee.fetch!()

      entity = metadata
               |> Metadata.random_entity()

      assert %Federation{id: :ukamf} = SmeeFeds.publisher(@federations_list, metadata)
      assert %Federation{id: :ukamf} = SmeeFeds.publisher(@federations_list, entity)
      assert %Federation{id: :ukamf} = SmeeFeds.publisher(@federations_list, source)

    end

    @tag timeout: 180_000
    test "returns the first federation (from the passed collection) that could have provided the supplied metadata or entity" do

      federations = SmeeFeds.federations([:ukamf, :incommon])

      source = Source.new("http://metadata.ukfederation.org.uk/ukfederation-metadata.xml")

      metadata = source
                 |> Smee.fetch!()

      entity = metadata
               |> Metadata.random_entity()

      assert %Federation{id: :ukamf} = SmeeFeds.publisher(federations, metadata)
      assert %Federation{id: :ukamf} = SmeeFeds.publisher(federations, entity)
      assert %Federation{id: :ukamf} = SmeeFeds.publisher(federations, source)

    end

    @tag timeout: 180_000
    test "returns nil if no publisher can be found" do
      federations = SmeeFeds.federations([:incommon, :wayf])

      source = Source.new("http://metadata.ukfederation.org.uk/ukfederation-metadata.xml")

      metadata = source
                 |> Smee.fetch!()

      entity = metadata
               |> Metadata.random_entity()

      assert nil == SmeeFeds.publisher(federations, metadata)
      assert nil == SmeeFeds.publisher(federations, entity)
      assert nil == SmeeFeds.publisher(federations, source)

    end

  end

  describe "countries/1" do

    test "returns a list of all known countries present in the provided federations list" do
      mini_feds = SmeeFeds.federations([:ukamf, :incommon])
      assert 2 = Enum.count(SmeeFeds.countries(mini_feds))
      assert is_list(SmeeFeds.countries(mini_feds))
    end

    test "countries are returned as full Country structs" do
      assert Enum.all?(SmeeFeds.countries(@federations_list), fn v -> %Country{} = v end)
    end

  end

  describe "regions/1" do

    test "returns a list of all known regions present in the provided federations list" do
      mini_feds = SmeeFeds.federations([:ukamf, :incommon])
      assert ["Americas", "Europe"] = SmeeFeds.regions(mini_feds)
      assert is_list(SmeeFeds.regions(@federations_list))
    end

    test "regions are returned as strings" do
      assert Enum.all?(SmeeFeds.regions(@federations_list), fn v -> is_binary(v) end)
    end

  end

  describe "sub_regions/1" do
    test "returns a list of all known sub_regions" do
      assert [
               "Australia and New Zealand",
               "Central America",
               "Central Asia",
               "Eastern Africa",
               "Eastern Asia",
               "Eastern Europe",
               "Northern Africa",
               "Northern America",
               "Northern Europe",
               "South America",
               "South-Eastern Asia",
               "Southern Africa",
               "Southern Asia",
               "Southern Europe",
               "Western Africa",
               "Western Asia",
               "Western Europe"
             ] = SmeeFeds.sub_regions(@federations_list)
      assert is_list(SmeeFeds.sub_regions(@federations_list))
    end

    test "returns a list of all known sub_regions present in provided federations list" do
      mini_feds = SmeeFeds.federations([:ukamf, :incommon])
      assert ["Northern America", "Northern Europe"] = SmeeFeds.sub_regions(mini_feds)
      assert is_list(SmeeFeds.sub_regions(mini_feds))
    end

    test "sub_regions are returned as strings" do
      assert Enum.all?(SmeeFeds.sub_regions(@federations_list), fn v -> is_binary(v) end)
    end

  end

  describe "super_regions/1" do

    test "returns a list of all known super_regions present in provided federations list" do
      mini_feds = SmeeFeds.federations([:ukamf, :incommon])
      assert ["AMER", "EMEA"] = SmeeFeds.super_regions(mini_feds)
      assert is_list(SmeeFeds.super_regions(mini_feds))
    end

    test "super_regions are returned as strings" do
      assert Enum.all?(SmeeFeds.super_regions(@federations_list), fn v -> is_binary(v) end)
    end

  end

  describe "types/1" do

    test "returns a list of all types used in the provided federation list" do
      assert [:inter, :misc, :nren] = SmeeFeds.types(@federations_list)
    end

  end

  describe "structures/1" do

    test "returns a list of all structures used in the provided federation list" do
      assert [:has, :mesh] = SmeeFeds.structures(@federations_list)
    end

  end

  describe "id_types/1" do

    test "returns a list of all id_types used in the provided federation list" do
      assert [:edugain, :met, :smee, :uri] = SmeeFeds.id_types(@federations_list)
    end

  end

  describe "protocols/1" do

    test "returns a list of all protocols used in the provided federation list" do
      assert [:saml2] = SmeeFeds.protocols(@federations_list)
    end

  end

  describe "upstream/1" do

    test "returns a list of all upstream used in the provided federation list" do
      assert [:edugain] = SmeeFeds.upstream(@federations_list)
    end

  end

  describe "tags/1" do

    test "returns a list of all tags used in the provided federation list" do
      assert ["noSlow", "noTest"] = SmeeFeds.tags(@federations_list)
    end

  end

  describe "get_by/3" do

    test "returns a federation record if one exists with the specified ID of ID type" do
      assert %Federation{id: :ukamf} = SmeeFeds.get_by(@federations_list, :uri, "http://ukfederation.org.uk")
    end

    test "returns a nil if no record exists with the specified ID of ID type" do
      assert is_nil(SmeeFeds.get_by(@federations_list, :uri, "http://example.com/not_there"))
    end

    test "returns a nil if passed a non-existent type of ID" do
      assert is_nil(SmeeFeds.get_by(@federations_list, :nonsense, "http://ukfederation.org.uk"))
    end

    test "is compatible with the URIs used to identity Federations" do
      assert %Federation{id: :ukamf} = SmeeFeds.get_by(@federations_list, :uri, "http://ukfederation.org.uk")
    end

    test "is compatible with the built-in SmeeFeds IDs, even if strings" do
      assert %Federation{id: :incommon} = SmeeFeds.get_by(@federations_list, :smee, :incommon)
      assert %Federation{id: :incommon} = SmeeFeds.get_by(@federations_list, :smee, "incommon")
    end

    test "works with IDs present in the default/test data included with SmeeFeds" do
      assert %Federation{id: :haka} = SmeeFeds.get_by(@federations_list, :edugain, "HAKA")
      assert %Federation{id: :fer} = SmeeFeds.get_by(@federations_list, :met, "federation-education-recherche")
    end

  end

  describe "autotag!/2" do

    test "runs autotag! on each federation in the enumerable" do
      assert 2 = SmeeFeds.federations()
                 |> SmeeFeds.tags()
                 |> Enum.count()
      assert 154 = SmeeFeds.federations()
                   |> SmeeFeds.autotag!()
                   |> SmeeFeds.tags()
                   |> Enum.count()
    end

  end

end
