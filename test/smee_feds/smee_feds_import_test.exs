defmodule SmeeFedsImportTest do
  use ExUnit.Case, async: false

  @default_data_file Path.join(Application.app_dir(:smee_feds, "priv"), "data/federations.json")
  @default_data_string File.read!(@default_data_file)

  @example_json_string "[{\"id\":\"dfnaai\",\"name\":\"DFN-AAI\",\"type\":\"nren\",\"protocols\":[\"saml2\"],\"sources\":{\"default\":{\"id\":\"default\",\"label\":\"default aggregate\",\"priority\":5,\"type\":\"aggregate\",\"strict\":false,\"cache\":true,\"auth\":null,\"url\":\"https://doku.tid.dfn.de/en:metadata\",\"tags\":[],\"trustiness\":0.5,\"cert_url\":\"https://www.aai.dfn.de/metadata/dfn-aai.pem\",\"cert_fingerprint\":\"28:0B:D5:0F:96:B8:60:8F:87:93:8C:73:C6:F1:16:63:CF:B2:2D:B2\",\"redirects\":3,\"retries\":5,\"fedid\":\"dfnaai\"},\"mdq\":{\"id\":\"mdq\",\"label\":\"mdq aggregate\",\"priority\":5,\"type\":\"aggregate\",\"strict\":false,\"cache\":true,\"auth\":null,\"url\":\"https://mdq.aai.dfn.de\",\"tags\":[],\"trustiness\":0.5,\"cert_url\":\"https://www.aai.dfn.de/metadata/dfn-aai-mdq.pem\",\"cert_fingerprint\":\"76:E6:8C:F1:AD:18:01:B2:4F:B3:66:5A:B2:BC:99:E2:14:B2:4F:05\",\"redirects\":3,\"retries\":5,\"fedid\":\"dfnaai\"}},\"uri\":\"https://www.aai.dfn.de\",\"countries\":[\"DE\"],\"url\":\"https://www.aai.dfn.de/\",\"tags\":[],\"contact\":\"hotline@aai.dfn.de\",\"alt_ids\":{\"edugain\":\"DFN-AAI\",\"met\":\"dfn-aai\"},\"structure\":\"mesh\",\"descriptions\":{},\"displaynames\":{},\"logo\":\"https://www.aai.dfn.de/static/img/dfn_aai_logo.png\",\"interfederates\":[\"edugain\"],\"policy\":\"https://doku.tid.dfn.de/en:join\",\"autotag\":false},{\"id\":\"edugate\",\"name\":\"Edugate\",\"type\":\"nren\",\"protocols\":[\"saml2\"],\"sources\":{\"default\":{\"id\":\"default\",\"label\":\"default aggregate\",\"priority\":5,\"type\":\"aggregate\",\"strict\":false,\"cache\":true,\"auth\":null,\"url\":\"https://edugate.heanet.ie/edugate-federation-metadata-signed.xml\",\"tags\":[],\"trustiness\":0.5,\"cert_url\":\"https://edugate.heanet.ie/metadata-signer-2012.crt\",\"cert_fingerprint\":\"44:6B:91:4D:9D:C7:C4:B4:09:DA:EE:91:38:82:2F:31:C1:F8:31:1E\",\"redirects\":3,\"retries\":5,\"fedid\":\"edugate\"}},\"uri\":\"http://www.heanet.ie\",\"countries\":[\"IE\"],\"url\":\"https://edugate.heanet.ie/\",\"tags\":[],\"contact\":\"noc@heanet.ie\",\"alt_ids\":{\"edugain\":\"EDUGATE\",\"met\":\"edugate-federation\"},\"structure\":\"mesh\",\"descriptions\":{},\"displaynames\":{},\"logo\":\"https://www.heanet.ie/wp-content/uploads/2019/11/edugate-logo.jpg\",\"interfederates\":[\"edugain\"],\"policy\":\"http://www.heanet.ie/services/identity-access/edugate#join\",\"autotag\":false}]"
  @example_json_file "test/support/static/eu_feds.json"

  alias SmeeFeds.Import
  alias SmeeFeds.Federation

  describe "dd_json!/2" do

    test "returns a map of federation data" do
      assert is_map(Import.dd_json!(@default_data_string))
    end

    test "all keys are atoms" do
      assert Enum.all?(Map.keys(Import.dd_json!(@default_data_string)), fn k -> is_atom(k) end)
    end

    test "all values are Federation structs" do
      assert Enum.all?(Map.values(Import.dd_json!(@default_data_string)), fn v -> is_struct(v, Federation) end)
    end

    test "when processing the default data over 60 records should be present" do
      assert 60 < Enum.count(Map.keys(Import.dd_json!(@default_data_string)))
    end

  end

  describe "dd_json_file!/2" do

    test "returns a map of federation data" do
      assert is_map(Import.dd_json_file!(@default_data_file))
    end

    test "all keys are atoms" do
      assert Enum.all?(Map.keys(Import.dd_json_file!(@default_data_file)), fn k -> is_atom(k) end)
    end

    test "all values are Federation structs" do
      assert Enum.all?(Map.values(Import.dd_json_file!(@default_data_file)), fn v -> is_struct(v, Federation) end)
    end

    test "when processing the default data over 60 records should be present" do
      assert 60 < Enum.count(Map.keys(Import.dd_json_file!(@default_data_file)))
    end

  end

  describe "json!/2" do

    test "returns a list when passed a suitable JSON string" do
     assert is_list(Import.json!(@example_json_string))
    end

    test "all values of the list are Federation structs" do
      assert Enum.all?(Import.json!(@example_json_string), fn v -> is_struct(v, Federation) end)
    end

    test "in this example, two Federation records should be returned" do
      assert 2 = Enum.count(Import.json!(@example_json_string))
    end

  end

  describe "json_file!/2" do

    test "returns a list when provided with a valid file name/path" do
      assert is_list(Import.json_file!(@example_json_file))
    end

    test "all values of the list are Federation structs" do
      assert Enum.all?(Import.json_file!(@example_json_file), fn v -> is_struct(v, Federation) end)
    end

    test "in this example, over 60 Federation records should be returned" do
      assert 23 = Enum.count(Import.json_file!(@example_json_file))
    end

  end

end
