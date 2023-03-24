defmodule SmeeFedsFilterTest do
  use ExUnit.Case

  alias SmeeFeds.Filter


  describe "eu/2" do

    test "by default only returns federations in the EU" do
      assert [
               :aaieduhr,
               :arnesaai,
               :belnet,
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
               :rctsaai,
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

      assert [:eduidmma, :eduidng, :rafiki, :rif, :safire] = SmeeFeds.federations
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
               :tigerfed,
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

end
