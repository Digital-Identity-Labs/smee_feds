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

end
