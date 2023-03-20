defmodule SmeeFedsDataLoaderTest do
  use ExUnit.Case, async: false

  alias SmeeFeds.DataLoader

  describe "load/0" do

    test "returns a map of federation data" do
      assert is_map(DataLoader.load())
    end

    test "all keys are atoms" do
      assert Enum.all?(Map.keys(DataLoader.load()), fn k -> is_atom(k) end)
    end

    test "all values are maps" do
      assert Enum.all?(Map.values(DataLoader.load()), fn v -> is_map(v) end)
    end

    test "by default over 60 records should be present" do
      assert 60 < Enum.count(Map.keys(DataLoader.load()))
    end

  end

  describe "file/0" do

    test "by default returns the location of built-in federation data" do
      assert String.ends_with?(
               DataLoader.file(),
               "smee_feds/_build/test/lib/smee_feds/priv/data/federations.json"
             )
    end

    test "the file actually exists too" do
      assert File.exists?(DataLoader.file())
    end

#    test "a new file can be defined using a config option" do
#
#      previous_value = Application.get_env(:smee_feds, :data_file)
#      Application.put_env(:smee_feds, :data_file, "test/support/static/small_federations.json")
#      on_exit(fn -> Application.put_env(:smee_feds, :data_file, previous_value) end)
#
#      assert String.ends_with?(
#               DataLoader.file(),
#               "test/support/static/small_federations.json"
#             )
#
#    end

  end

end
