defmodule SmeeFedsFilterTest do
  use ExUnit.Case

  alias SmeeFeds.Filter


  describe "eu/2" do

    test "by default only returns federations in the EU" do
      assert [
               :aaieduhr,
               :arnesaai,
               :bif,
               :cynet,
               :dfnaai,
               :edugate,
               :eduidcz,
               :eduidhu,
               :fer,
               :grnet,
               :haka,
               :idem,
               :laife,
               :litnet,
               :pionier,
               :ricerka,
               :roedunetid,
               :safeid,
               :sir,
               :surfconext,
               :swamid,
               :taat,
               :wayf
             ] = SmeeFeds.federations
                 |> Filter.eu()
                 |> SmeeFeds.ids()
                 |> Enum.sort()
    end

    test "No UK/GB in the resulting list" do
      eu_list = SmeeFeds.federations
                |> Filter.eu()
                |> SmeeFeds.ids()
      refute Enum.member?(eu_list, :ukamf)
    end

    test "if passed false as a second parameter, inverts filter to only returns federations outside the EU" do
      not_eu_list = SmeeFeds.federations
                    |> Filter.eu(false)
                    |> SmeeFeds.ids()
      assert Enum.member?(not_eu_list, :ukamf)
    end

  end

  describe "region/3" do

    test "Only returns federations in the specified region" do

      assert [:eduidmma, :eduidng, :rafiki, :safire] = SmeeFeds.federations
                                                       |> Filter.region("Africa")
                                                       |> SmeeFeds.ids()
                                                       |> Enum.sort()

    end

    test "if passed false as a second parameter, inverts filter to only returns federations outside the region" do
      not_africa = SmeeFeds.federations
                   |> Filter.region("Africa", false)
                   |> SmeeFeds.ids()
      assert Enum.member?(not_africa, :ukamf)
    end

  end

  describe "sub_region/2" do

    test "Only returns federations in the specified subregion" do

      assert [:aaf, :tuakiri] = SmeeFeds.federations
                                |> Filter.sub_region("Australia and New Zealand")
                                |> SmeeFeds.ids()
                                |> Enum.sort()

    end

    test "if passed false as a second parameter, inverts filter to only returns federations outside the subregion" do
      not_ausnz = SmeeFeds.federations
                  |> Filter.sub_region("Australia and New Zealand", false)
                  |> SmeeFeds.ids()
      assert Enum.member?(not_ausnz, :ukamf)
    end

  end

  describe "super_region/3" do

    test "Only returns federations in the specified super region" do

      assert [
               :aaf,
               :carsi,
               :cst,
               :federasi,
               :gakunin,
               :hkaf,
               :infed,
               :kafe,
               :liaf,
               :pkifed,
               :sgaf,
               :sifulan,
               :thaildf,
               :tuakiri
             ] = SmeeFeds.federations
                 |> Filter.super_region("APAC")
                 |> SmeeFeds.ids()
                 |> Enum.sort()

    end

    test "if passed false as a second parameter, inverts filter to only returns federations outside the super region" do
      not_apac = SmeeFeds.federations
                 |> Filter.super_region("APAC", false)
                 |> SmeeFeds.ids()
      assert Enum.member?(not_apac, :ukamf)
    end

  end

  describe "id_type/3" do

    test "only returns federations with an ID of the specified type" do
      assert 57 = SmeeFeds.federations
                  |> Filter.id_type(:met)
                  |> Enum.count()
    end

    test "inverts the results if false is passed" do
      assert [:bif, :cynet, :eduidafrica, :eduidng, :federasi, :fiel, :iamres, :rash, :thaildf] = SmeeFeds.federations
                                                                                                  |> Filter.id_type(
                                                                                                       :met,
                                                                                                       false
                                                                                                     )
                                                                                                  |> SmeeFeds.ids()
    end

  end

  describe "type/3" do

    test "only returns federations with an type of the specified type" do
      assert 65 = SmeeFeds.federations
                  |> Filter.type(:nren)
                  |> Enum.count()
    end

    test "inverts the results if false is passed" do
      assert 1 = SmeeFeds.federations
                 |> Filter.type(:nren, false)
                 |> Enum.count()
    end

  end

  describe "structure/3" do

    test "only returns federations with a structure of the specified type" do
      assert [
               :aaieduhr,
               :athens,
               :feide,
               :iuccif,
               :roedunetid,
               :safire,
               :sir,
               :surfconext,
               :taat,
               :wayf
             ] = SmeeFeds.federations
                 |> Filter.structure(:has)
                 |> SmeeFeds.ids()
    end

    test "inverts the results if false is passed" do
      assert 56 = SmeeFeds.federations
                  |> Filter.structure(:has, false)
                  |> Enum.count()
    end

  end

  describe "tag/3" do

    test "only returns federations with a matching tag" do
      assert [
               :aaieduhr,
               :athens,
               :feide,
               :iuccif,
               :roedunetid,
               :safire,
               :sir,
               :surfconext,
               :taat,
               :wayf
             ] = SmeeFeds.federations()
                 |> SmeeFeds.autotag!()
                 |> Filter.tag("has")
                 |> SmeeFeds.ids()
    end

    test "inverts the results if false is passed" do
      assert 56 = SmeeFeds.federations()
                  |> SmeeFeds.autotag!()
                  |> Filter.tag("has", false)
                  |> Enum.count()
    end

  end

  describe "protocol/3" do

    test "only returns federations with a matching protocol" do
      assert 66 = SmeeFeds.federations
                  |> Filter.protocol(:saml2)
                  |> Enum.count()
      assert 0 = SmeeFeds.federations
                 |> Filter.protocol(:cas)
                 |> Enum.count()
    end

    test "inverts the results if false is passed" do
      assert 66 = SmeeFeds.federations
                  |> Filter.protocol(:cas, false)
                  |> Enum.count()
    end

  end

  describe "interfederates/3" do

    test "only returns federations interfederating with the specified federation ID" do
      assert 64 = SmeeFeds.federations
                  |> Filter.interfederates(:edugain)
                  |> Enum.count()
    end

    test "inverts the results if false is passed" do
      assert 2 = SmeeFeds.federations
                 |> Filter.interfederates(:edugain, false)
                 |> Enum.count()
    end

  end

  describe "aggregate/3" do

    test "only returns federations that provide an aggregate" do
      assert 66 = SmeeFeds.federations
                  |> Filter.aggregate()
                  |> Enum.count()
    end

    test "inverts the results if false is passed" do
      assert 0 = SmeeFeds.federations
                 |> Filter.aggregate(false)
                 |> Enum.count()
    end

  end

  describe "mdq/3" do

    test "only returns federations that provide an MDQ service" do
      assert [:dfnaai, :incommon, :ukamf] = SmeeFeds.federations
                                            |> Filter.mdq()
                                            |> SmeeFeds.ids()
    end

    test "inverts the results if false is passed" do
      assert 63 = SmeeFeds.federations
                  |> Filter.mdq(false)
                  |> Enum.count()
    end

  end

end
