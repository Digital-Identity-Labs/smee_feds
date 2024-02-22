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

    test "returns the contact information as an email address, if it's present" do
      assert "service@ukfederation.org.uk" = Federation.contact(SmeeFeds.federation(:ukamf))
    end

    test "returns nil if contact address is not present" do
      assert Federation.contact(struct(SmeeFeds.federation(:ukamf), %{contact: nil})) == nil
    end

  end

  describe "sources/1" do

    test "returns federation metadata as a list of sources, if any are present" do
      assert is_list(Federation.sources(SmeeFeds.federation(:ukamf)))
      assert Enum.all?(Federation.sources(SmeeFeds.federation(:ukamf)), fn v -> %Smee.Source{} = v end)
    end

    test "returns an empty list if nothing is present" do
      assert [] = Federation.sources(struct(SmeeFeds.federation(:ukamf), %{sources: %{}}))
    end

  end

  describe "aggregate/1" do

    test "returns the default aggregate as a Smee Source if it exists" do
      assert %Source{type: :aggregate} = Federation.aggregate(SmeeFeds.federation(:ukamf))
    end

    test "returns the first aggregate as a Smee Source if no default exists" do
      assert %Source{type: :aggregate, url: "http://example.com"} = Federation.aggregate(
               struct(
                 SmeeFeds.federation(:ukamf),
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
      assert is_nil(Federation.aggregate(struct(SmeeFeds.federation(:ukamf), %{sources: nil})))
    end

  end

  describe "mdq/1" do

    test "returns the default MDQ service as a Smee Source if it exists" do
      assert %Source{type: :mdq} = Federation.mdq(SmeeFeds.federation(:ukamf))
    end

    test "returns the first aggregate as a Smee Source if no default exists" do
      assert %Source{type: :mdq, url: "http://example2.com"} = Federation.mdq(
               struct(
                 SmeeFeds.federation(:ukamf),
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
      assert is_nil(Federation.aggregate(struct(SmeeFeds.federation(:ukamf), %{sources: nil})))
    end


  end

  describe "url/1" do

    test "returns the url as a string if one is present" do
      assert "http://www.ukfederation.org.uk/" = Federation.url(SmeeFeds.federation(:ukamf))
    end

    test "if no url is present, returns a nil" do
      assert is_nil(Federation.url(struct(SmeeFeds.federation(:ukamf), %{url: nil})))
    end

  end

  describe "policy_url/1" do

    test "returns the policy url as a string if one is present" do
      assert "http://www.ukfederation.org.uk/library/uploads/Documents/rules-of-membership.pdf" = Federation.policy_url(
               SmeeFeds.federation(:ukamf)
             )
    end

    test "if no policy url is present, returns a nil" do
      assert is_nil(Federation.policy_url(struct(SmeeFeds.federation(:ukamf), %{policy: nil})))
    end

  end

  describe "countries/1" do

    test "returns a list of country structs associated with the federation" do
      assert [%Country{}] = Federation.countries(SmeeFeds.federation(:ukamf))
    end

    test "if no countries are associated, always return an empty list" do
      assert [] = Federation.countries(struct(SmeeFeds.federation(:ukamf), %{countries: nil}))
    end

  end

  describe "Protocol String.Chars.to_string/1" do
    assert "#[Federation http://ukfederation.org.uk]" = "#{SmeeFeds.federation(:ukamf)}"
  end

  describe "Protocol Jason Encoder" do
    assert "{\"id\":\"ukamf\",\"name\":\"UK Access Management Federation\",\"type\":\"nren\",\"protocols\":[\"saml2\"],\"sources\":{\"default\":{\"id\":\"default\",\"label\":\"UK Access Management Federation: default aggregate\",\"priority\":5,\"type\":\"aggregate\",\"strict\":false,\"cache\":true,\"auth\":null,\"url\":\"http://metadata.ukfederation.org.uk/ukfederation-metadata.xml\",\"tags\":[],\"trustiness\":0.5,\"cert_url\":\"http://metadata.ukfederation.org.uk/ukfederation.pem\",\"cert_fingerprint\":\"AD:80:7A:6D:26:8C:59:01:55:47:8D:F1:BA:61:68:10:DA:81:86:66\",\"redirects\":3,\"retries\":5,\"fedid\":null},\"mdq\":{\"id\":\"mdq\",\"label\":\"UK Access Management Federation: mdq mdq\",\"priority\":5,\"type\":\"mdq\",\"strict\":false,\"cache\":true,\"auth\":null,\"url\":\"http://mdq.ukfederation.org.uk/\",\"tags\":[],\"trustiness\":0.5,\"cert_url\":\"http://mdq.ukfederation.org.uk/ukfederation-mdq.pem\",\"cert_fingerprint\":\"3F:6B:F4:AF:E0:1B:3C:D7:C1:F2:3D:F6:EA:C5:60:AE:B1:5A:E8:26\",\"redirects\":3,\"retries\":5,\"fedid\":null}},\"uri\":\"http://ukfederation.org.uk\",\"countries\":[\"GB\"],\"url\":\"http://www.ukfederation.org.uk/\",\"tags\":[],\"contact\":\"service@ukfederation.org.uk\",\"alt_ids\":{\"edugain\":\"UK-FEDERATION\",\"met\":\"uk-access-management-federation\"},\"descriptions\":{},\"displaynames\":{},\"policy\":\"http://www.ukfederation.org.uk/library/uploads/Documents/rules-of-membership.pdf\",\"logo\":\"https://www.ukfederation.org.uk/library/uploads/Documents/Logo2.jpg\",\"structure\":\"mesh\",\"interfederates\":[\"edugain\"],\"autotag\":false}" =
             Jason.encode!(SmeeFeds.federation(:ukamf))
  end

end
