defmodule SmeeFedsDataTest do
  use ExUnit.Case

  alias SmeeFeds.Data
  alias SmeeFeds.Federation

  describe "federations/0" do

    test "returns a map of federation data" do
      assert is_map(Data.federations())
    end

    test "all keys are atoms" do
      assert Enum.all?(Map.keys(Data.federations()), fn k -> is_atom(k) end)
    end

    test "all values are structs (Federation records)" do
      assert Enum.all?(Map.values(Data.federations()), fn v -> %Federation{} = v end)
    end

    test "by default over 60 records should be present" do
      assert 60 < Enum.count(Map.keys(Data.federations()))
    end

  end

  describe "Brexit (without swearing)" do

    test "UK is no longer part of the EU but Countries library hasn't been updated, so manually fixed" do
      assert %Countries.Country{eu_member: false} = Map.get(Data.federations(), :ukamf) |> Federation.countries() |> List.first()
    end

  end

end
