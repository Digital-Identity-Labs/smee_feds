defmodule SmeeFedsDefaultDataTest do
  use ExUnit.Case

  alias SmeeFeds.DefaultData
  alias SmeeFeds.Federation

  describe "federations/0" do

    test "returns a map of federation data" do
      assert is_map(DefaultData.federations())
    end

    test "all keys are atoms" do
      assert Enum.all?(Map.keys(DefaultData.federations()), fn k -> is_atom(k) end)
    end

    test "all values are structs (Federation records)" do
      assert Enum.all?(Map.values(DefaultData.federations()), fn v -> %Federation{} = v end)
    end

    test "by default over 60 records should be present" do
      assert 60 < Enum.count(Map.keys(DefaultData.federations()))
    end

  end


  describe "file/0" do

    test "by default returns the location of built-in federation data" do
      assert String.ends_with?(
               DefaultData.file(),
               "smee_feds/_build/test/lib/smee_feds/priv/data/federations.json"
             )
    end

    test "the file actually exists too" do
      assert File.exists?(DefaultData.file())
    end

  end

  describe "Brexit (without swearing)" do

    test "UK is no longer part of the EU but Countries library hasn't been updated, so manually fixed (now fixed by changing library)" do
      assert %BeamLabCountries.Country{eu_member: false} = Map.get(DefaultData.federations(), :ukamf)
                                                    |> Federation.countries()
                                                    |> List.first()
    end

  end

end
