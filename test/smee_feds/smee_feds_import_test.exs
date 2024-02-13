defmodule SmeeFedsDataLoaderTest do
  use ExUnit.Case, async: false

  @default_data_file Path.join(Application.app_dir(:smee_feds, "priv"), "data/federations.json")

  alias SmeeFeds.Import

  describe "load/0" do

    test "returns a map of federation data" do
      assert is_map(Import.load!(@default_data_file))
    end

    test "all keys are atoms" do
      assert Enum.all?(Map.keys(Import.load!(@default_data_file)), fn k -> is_atom(k) end)
    end

    test "all values are maps" do
      assert Enum.all?(Map.values(Import.load!(@default_data_file)), fn v -> is_map(v) end)
    end

    test "by default over 60 records should be present" do
      assert 60 < Enum.count(Map.keys(Import.load!(@default_data_file)))
    end

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
#
#  end

end
