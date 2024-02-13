defmodule SmeeFedsFederationTest do
  use ExUnit.Case
  doctest SmeeFeds.Federation

  alias SmeeFeds.Federation
  alias Smee.Source
  alias Countries.Country

  describe "new/2" do

    test "returns a new Federation struct when passed an ID" do
      assert %Federation{id: :example} = Federation.new(:example)
    end

    test "apart from the ID other attributes are empty" do
      assert %Federation{
               id: :example,
               contact: nil,
               name: nil,
               url: nil,
               countries: [],
               policy: nil,
               sources: %{}
             } = Federation.new(:example)
    end

  end

  describe "contact/1" do

    test "returns the contact information as a URL, if it's present" do
      assert "mailto:service@ukfederation.org.uk" = Federation.contact(SmeeFeds.get(:ukamf))
    end

    test "returns nil if contact address is not present" do
      assert Federation.contact(struct(SmeeFeds.get(:ukamf), %{contact: nil})) == nil
    end

  end

  describe "sources/1" do

    test "returns federation metadata as a list of sources, if any are present" do
      assert is_list(Federation.sources(SmeeFeds.get(:ukamf)))
      assert Enum.all?(Federation.sources(SmeeFeds.get(:ukamf)), fn v -> %Smee.Source{} = v end)
    end

    test "returns an empty list if nothing is present" do
      assert [] = Federation.sources(struct(SmeeFeds.get(:ukamf), %{sources: %{}}))
    end

  end

  describe "aggregate/1" do

    test "returns the default aggregate as a Smee Source if it exists" do
      assert %Source{type: :aggregate} = Federation.aggregate(SmeeFeds.get(:ukamf))
    end

    test "returns the first aggregate as a Smee Source if no default exists" do
      assert %Source{type: :aggregate, url: "http://example.com"} = Federation.aggregate(
               struct(
                 SmeeFeds.get(:ukamf),
                 %{
                   sources: %{
                     mdq: Source.new("http://example2.com", type: :mdq),
                     example: Source.new("http://example.com")
                   }
                 }
               )
             )
    end

    test "returns nil if no aggregate is available at all" do
      assert is_nil(Federation.aggregate(struct(SmeeFeds.get(:ukamf), %{sources: nil})))
    end

  end

  describe "mdq/1" do

    test "returns the default MDQ service as a Smee Source if it exists" do
      assert %Source{type: :mdq} = Federation.mdq(SmeeFeds.get(:ukamf))
    end

    test "returns the first aggregate as a Smee Source if no default exists" do
      assert %Source{type: :mdq, url: "http://example2.com"} = Federation.mdq(
               struct(
                 SmeeFeds.get(:ukamf),
                 %{
                   sources: %{
                     example2: Source.new("http://example.com"),
                     example1: Source.new("http://example2.com", type: :mdq),
                   }
                 }
               )
             )
    end

    test "returns nil if no aggregate is available at all" do
      assert is_nil(Federation.aggregate(struct(SmeeFeds.get(:ukamf), %{sources: nil})))
    end


  end

  describe "url/1" do

    test "returns the url as a string if one is present" do
      assert "http://www.ukfederation.org.uk/" = Federation.url(SmeeFeds.get(:ukamf))
    end

    test "if no url is present, returns a nil" do
      assert is_nil(Federation.url(struct(SmeeFeds.get(:ukamf), %{url: nil})))
    end

  end

  describe "policy_url/1" do

    test "returns the policy url as a string if one is present" do
      assert "http://www.ukfederation.org.uk/library/uploads/Documents/rules-of-membership.pdf" = Federation.policy_url(SmeeFeds.get(:ukamf))
    end

    test "if no policy url is present, returns a nil" do
      assert is_nil(Federation.policy_url(struct(SmeeFeds.get(:ukamf), %{policy: nil})))
    end

  end

  describe "countries/1" do

    test "returns a list of country structs associated with the federation" do
      assert [%Country{}] = Federation.countries(SmeeFeds.get(:ukamf))
    end

    test "if no countries are associated, always return an empty list" do
      assert [] = Federation.countries(struct(SmeeFeds.get(:ukamf), %{countries: nil}))
    end

  end

end
