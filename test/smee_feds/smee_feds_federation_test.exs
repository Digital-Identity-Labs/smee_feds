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

    test "IDs passed as options are accepted but ignored" do
      assert %Federation{id: :bar} = Federation.new(:bar, id: "foo")
    end

    test "apart from the ID other attributes are empty, or defaults" do
      assert %Federation{
               id: :example,
               contact: nil,
               name: nil,
               url: nil,
               uri: nil,
               countries: [],
               policy: nil,
               sources: %{},
               displaynames: %{},
               descriptions: %{},
               alt_ids: %{},
               tags: [],
               interfederates: [],
               logo: nil,
               structure: :mesh,
               type: :local,
               protocols: [:saml2]
             } = Federation.new(:example)
    end

    test "contact can be set as an option" do
      assert %Federation{contact: "pete@example.com"} = Federation.new(:test, contact: "pete@example.com")
    end

    test "contact can be set as an option, and will have a mailto: scheme removed" do
      assert %Federation{contact: "pete@example.com"} = Federation.new(:test, contact: "mailto:pete@example.com")
    end

    test "alt_ids can be set as an option, using a map" do
      assert %Federation{
               alt_ids: %{
                 other_org: "TEST"
               }
             } = Federation.new(
               :test,
               alt_ids: %{
                 other_org: "TEST"
               }
             )
    end

    test "type can be set as an option, as string or atom" do
      assert %Federation{type: :nren} = Federation.new(:test, type: "nren")
      assert %Federation{type: :nren} = Federation.new(:test, type: :nren)
    end

    test "structure can be set as an option" do
      assert %Federation{structure: :has} = Federation.new(:test, structure: "has")
      assert %Federation{structure: :has} = Federation.new(:test, structure: :has)
    end

    test "descriptions can be set as an option" do
      assert %Federation{
               descriptions: %{
                 en: "English desc"
               }
             } = Federation.new(
               :test,
               descriptions: %{
                 en: "English desc"
               }
             )
    end

    test "displaynames can be set as an option" do
      assert %Federation{
               displaynames: %{
                 en: "English name"
               }
             } = Federation.new(
               :test,
               displaynames: %{
                 en: "English name"
               }
             )
    end

    test "logo can be set as an option" do
      assert %Federation{logo: "http://example.com/logo.png"} = Federation.new(
               :test,
               logo: "http://example.com/logo.png"
             )
    end

    test "interfederates can be set as an option" do
      assert %Federation{interfederates: [:interorg]} = Federation.new(:test, interfederates: [:interorg])
    end

    test "tags can be set as an option" do
      assert %Federation{tags: ["test"]} = Federation.new(:test, tags: ["test"])
    end

    test "protocols can be set as an option" do
      assert %Federation{protocols: [:cas, :openid]} = Federation.new(:test, protocols: [:cas, :openid])
    end

    test "name can be set as an option" do
      assert %Federation{name: "example test"} = Federation.new(:test, name: "example test")
    end

    test "url can be set as an option" do
      assert %Federation{url: "https://example.com/home"} = Federation.new(:test, url: "https://example.com/home")
    end

    test "uri can be set as an option" do
      assert %Federation{uri: "https://example.com"} = Federation.new(:test, uri: "https://example.com")

    end

    test "countries can be set as an option" do
      assert %Federation{countries: ["NZ"]} = Federation.new(:test, countries: ["nz"])
    end

    test "policy can be set as an option" do
      assert %Federation{policy: "https://example.com/foo"} = Federation.new(:test, policy: "https://example.com/foo")
    end

    test "sources can be set as an option, as a map of IDs to source options as a map" do
      assert %Federation{
               sources: %{
                 a: %Source{
                   id: :a,
                   url: "http://example.com/a"
                 },
                 b: %Source{
                   id: :b,
                   url: "http://example.com/b"
                 }
               }
             } = Federation.new(
               :test,
               sources: %{
                 a: %{
                   url: "http://example.com/a"
                 },
                 b: %{
                   url: "http://example.com/b"
                 }
               }
             )
    end

    test "sources can be set as an option, as a map of IDs to source options as a map of keyword lists" do
      assert %Federation{
               sources: %{
                 a: %Source{
                   id: :a,
                   url: "http://example.com/a"
                 },
                 b: %Source{
                   id: :b,
                   url: "http://example.com/b"
                 }
               }
             } = Federation.new(
               :test,
               sources: %{
                 a: [
                   url: "http://example.com/a"
                 ],
                 b: [
                   url: "http://example.com/b"
                 ]
               }
             )
    end

    test "sources can be set as an option, as a list of Source structs without IDs" do
      assert %Federation{
               sources: %{
                 source0: %Source{
                   id: :source0
                 },
                 source1: %Source{
                   id: :source1
                 }
               }
             } = Federation.new(
               :test,
               sources: [Source.new("https://example.com/foo"), Source.new("https://example.com/bar")]
             )
    end

    test "sources can be set as an option, as a list of Source structs with IDs" do
      assert %Federation{
               sources: %{
                 default: %Source{
                   id: :default,
                   url: "https://example.com/foo"
                 },
                 mdq: %Source{
                   id: :mdq,
                   url: "https://example.com/bar"
                 }
               }
             } = Federation.new(
               :test,
               sources: [
                 Source.new("https://example.com/foo", id: :default),
                 Source.new("https://example.com/bar", id: :mdq)
               ]
             )
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
    assert "{\"id\":\"ukamf\",\"name\":\"UK Access Management Federation\"" <> _ =
             Jason.encode!(SmeeFeds.federation(:ukamf))
  end

  describe "tags/1" do

    test "returns a list of tags" do
      entity = struct(SmeeFeds.federation(:ukamf), %{tags: ["a", "b", "c"]})
      assert ["a", "b", "c"] = Federation.tags(entity)
    end

    test "returns an empty list even if tags value is nil" do
      entity = struct(SmeeFeds.federation(:ukamf), %{tags: nil})
      assert [] = Federation.tags(entity)
    end

  end

  describe "tag/2" do

    test "sets all tags, overwriting existing tags, as a sorted, unique list of tags as strings" do
      federation = struct(SmeeFeds.federation(:ukamf), %{tags: ["a", :b, 5]})
      %Federation{tags: ["0", "bar", "foo"]} = Federation.tag(federation, [:foo, "bar", 0])
    end

    test "list can be set with a single string" do
      federation = struct(SmeeFeds.federation(:ukamf), %{tags: ["a", :b, 5]})
      %Federation{tags: ["custard"]} = Federation.tag(federation, "custard")
    end

  end

  describe "sources/2" do

    test "Sets the provided list of Source structs as the Federation's Sources" do
      sources = [Source.new("https://example.com/foo"), Source.new("https://example.com/bar")]
      assert %Federation{
               sources: %{
                 source0: %Source{
                   url: "https://example.com/foo",
                   id: :source0
                 },
                 source1: %Source{
                   url: "https://example.com/bar",
                   id: :source1
                 }
               }
             } = SmeeFeds.federation(:ukamf)
                 |> SmeeFeds.Federation.sources(sources)
    end

    test "If sources have their own IDs, those will be used to index them in the Federation" do
      sources = [Source.new("https://example.com/foo", id: :default), Source.new("https://example.com/bar", id: :beta)]
      assert %Federation{
               sources: %{
                 default: %Source{
                   url: "https://example.com/foo",
                   id: :default
                 },
                 beta: %Source{
                   url: "https://example.com/bar",
                   id: :beta
                 }
               }
             } = SmeeFeds.federation(:ukamf)
                 |> SmeeFeds.Federation.sources(sources)
    end

  end

end
