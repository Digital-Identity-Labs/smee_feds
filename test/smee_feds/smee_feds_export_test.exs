defmodule SmeeFedsExportTest do
  use ExUnit.Case

  alias SmeeFeds.Export
  alias SmeeFeds.Federation

  describe "csv/1" do

    test "generates a valid CSV file as a binary string using the default list of federations" do
      assert is_binary(Export.csv())
    end

    test "generates a valid CSV file as a binary string when passed a list of federations" do
      assert is_binary(Export.csv(SmeeFeds.federations([:ukamf, :incommon])))
    end

    test "generates a valid CSV file that can be read by CSV library" do
      csv = Export.csv()

      {:ok, csv_stream} = StringIO.open(csv)

      assert [
               [
                 "aaf",
                 "Australian Access Federation (AAF)",
                 "http://www.aaf.edu.au/",
                 "AU",
                 "https://aaf.edu.au/about/federation-rules.html",
                 "support@aaf.edu.au",
                 "https://md.aaf.edu.au/aaf-metadata.xml",
                 ""
               ],
               [
                 "aaieduhr",
                 "AAI@EduHr",
                 "http://www.aaiedu.hr/",
                 "HR",
                 "http://www.aaiedu.hr/docs/AAI@EduHr-pravilnik-ver1.3.1.pdf",
                 "team@aaiedu.hr",
                 "https://login.aaiedu.hr/edugain/aaieduhr_edugain.xml",
                 ""
               ]
             ] = CSV.decode!(IO.binstream(csv_stream, :line))
                 |> Enum.sort()
                 |> Enum.take(2)



    end

  end

  describe "markdown/1" do

    test "generates a markdown table as a binary string using default list of federations" do
      assert is_binary(Export.markdown())
    end

    test "generates a markdown table as a binary string when passed a list of federations" do
      markdown = Export.markdown(SmeeFeds.federations([:ukamf, :incommon]))

      expected_markdown = "| ID | Name | URL | Countries | Policy URL | Contact | Aggregate URL | MDQ URL |\n|----|-----|-----|-----------|--------|---------|-----------|-----|\n| ukamf| UK Access Management Federation| http://www.ukfederation.org.uk/| gb| http://www.ukfederation.org.uk/library/uploads/Documents/rules-of-membership.pdf| service@ukfederation.org.uk| http://metadata.ukfederation.org.uk/ukfederation-metadata.xml| http://mdq.ukfederation.org.uk/| \n| incommon| InCommon| http://incommon.org/| us| https://incommon.org/about/policies/| help@incommon.org| https://md.incommon.org/InCommon/InCommon-metadata.xml| https://mdq.incommon.org|"
                          |> String.trim()
      assert ^expected_markdown = String.trim(markdown)
    end

  end

  describe "dd_json!/1" do

    test "exports the specified federations as a JSON formatted string if passed a list of federations" do
      assert is_binary(Export.dd_json!(SmeeFeds.federations([:ukamf, :incommon])))

      expected_json = "{\"ukamf\":{\"id\":\"ukamf\",\"name\":\"UK Access Management Federation\",\"type\":\"nren\",\"protocols\":[\"saml2\"],\"sources\":{\"default\":{\"id\":\"default\",\"label\":\"default aggregate\",\"priority\":5,\"type\":\"aggregate\",\"strict\":false,\"cache\":true,\"auth\":null,\"url\":\"http://metadata.ukfederation.org.uk/ukfederation-metadata.xml\",\"tags\":[],\"trustiness\":0.5,\"cert_url\":\"http://metadata.ukfederation.org.uk/ukfederation.pem\",\"cert_fingerprint\":\"AD:80:7A:6D:26:8C:59:01:55:47:8D:F1:BA:61:68:10:DA:81:86:66\",\"redirects\":3,\"retries\":5,\"fedid\":\"ukamf\"},\"mdq\":{\"id\":\"mdq\",\"label\":\"mdq mdq\",\"priority\":5,\"type\":\"mdq\",\"strict\":false,\"cache\":true,\"auth\":null,\"url\":\"http://mdq.ukfederation.org.uk/\",\"tags\":[],\"trustiness\":0.5,\"cert_url\":\"http://mdq.ukfederation.org.uk/ukfederation-mdq.pem\",\"cert_fingerprint\":\"3F:6B:F4:AF:E0:1B:3C:D7:C1:F2:3D:F6:EA:C5:60:AE:B1:5A:E8:26\",\"redirects\":3,\"retries\":5,\"fedid\":\"ukamf\"}},\"uri\":\"http://ukfederation.org.uk\",\"countries\":[\"GB\"],\"url\":\"http://www.ukfederation.org.uk/\",\"tags\":[],\"contact\":\"service@ukfederation.org.uk\",\"alt_ids\":{\"edugain\":\"UK-FEDERATION\",\"met\":\"uk-access-management-federation\"},\"descriptions\":{},\"displaynames\":{},\"policy\":\"http://www.ukfederation.org.uk/library/uploads/Documents/rules-of-membership.pdf\",\"logo\":\"https://www.ukfederation.org.uk/library/uploads/Documents/Logo2.jpg\",\"structure\":\"mesh\",\"interfederates\":[\"edugain\"],\"autotag\":false},\"incommon\":{\"id\":\"incommon\",\"name\":\"InCommon\",\"type\":\"nren\",\"protocols\":[\"saml2\"],\"sources\":{\"default\":{\"id\":\"default\",\"label\":\"default aggregate\",\"priority\":5,\"type\":\"aggregate\",\"strict\":false,\"cache\":true,\"auth\":null,\"url\":\"https://md.incommon.org/InCommon/InCommon-metadata.xml\",\"tags\":[],\"trustiness\":0.5,\"cert_url\":null,\"cert_fingerprint\":null,\"redirects\":3,\"retries\":5,\"fedid\":\"incommon\"},\"mdq\":{\"id\":\"mdq\",\"label\":\"mdq mdq\",\"priority\":5,\"type\":\"mdq\",\"strict\":false,\"cache\":true,\"auth\":null,\"url\":\"https://mdq.incommon.org\",\"tags\":[],\"trustiness\":0.5,\"cert_url\":\"http://md.incommon.org/certs/inc-md-cert-mdq.pem\",\"cert_fingerprint\":\"F8:4E:F8:47:EF:BB:EE:47:86:32:DB:94:17:8A:31:A6:94:73:19:36\",\"redirects\":3,\"retries\":5,\"fedid\":\"incommon\"}},\"uri\":\"https://incommon.org\",\"countries\":[\"US\"],\"url\":\"http://incommon.org/\",\"tags\":[],\"contact\":\"help@incommon.org\",\"alt_ids\":{\"edugain\":\"InCommon\",\"met\":\"incommon-federation\"},\"descriptions\":{},\"displaynames\":{},\"policy\":\"https://incommon.org/about/policies/\",\"logo\":\"https://incommon.org/wp-content/uploads/2019/08/Incommon2x.png\",\"structure\":\"mesh\",\"interfederates\":[\"edugain\"],\"autotag\":false}}"
      assert ^expected_json = Export.dd_json!(SmeeFeds.federations([:incommon, :ukamf]))
    end

    test "The string can be parsed as JSON to return a map of federations" do
      json_string = Export.dd_json!(SmeeFeds.federations())
      assert Enum.all?(Map.values(SmeeFeds.Import.dd_json!(json_string)), fn v -> is_struct(v, Federation) end)
    end

  end


  describe "dd_json_file!/1" do

    @tag :tmp_dir
    test "writes the specified federations as a JSON formatted file if passed a path and list of federations, returning :ok", %{tmp_dir: tmp_dir} do

      filepath = "#{tmp_dir}/test.json"
      federations = SmeeFeds.federations([:ukamf, :incommon])
      assert :ok = Export.dd_json_file!(federations, filepath)

      content = File.read!(filepath)
      assert is_binary(content)

      expected_json = "{\"ukamf\":{\"id\":\"ukamf\",\"name\":\"UK Access Management Federation\",\"type\":\"nren\",\"protocols\":[\"saml2\"],\"sources\":{\"default\":{\"id\":\"default\",\"label\":\"default aggregate\",\"priority\":5,\"type\":\"aggregate\",\"strict\":false,\"cache\":true,\"auth\":null,\"url\":\"http://metadata.ukfederation.org.uk/ukfederation-metadata.xml\",\"tags\":[],\"trustiness\":0.5,\"cert_url\":\"http://metadata.ukfederation.org.uk/ukfederation.pem\",\"cert_fingerprint\":\"AD:80:7A:6D:26:8C:59:01:55:47:8D:F1:BA:61:68:10:DA:81:86:66\",\"redirects\":3,\"retries\":5,\"fedid\":\"ukamf\"},\"mdq\":{\"id\":\"mdq\",\"label\":\"mdq mdq\",\"priority\":5,\"type\":\"mdq\",\"strict\":false,\"cache\":true,\"auth\":null,\"url\":\"http://mdq.ukfederation.org.uk/\",\"tags\":[],\"trustiness\":0.5,\"cert_url\":\"http://mdq.ukfederation.org.uk/ukfederation-mdq.pem\",\"cert_fingerprint\":\"3F:6B:F4:AF:E0:1B:3C:D7:C1:F2:3D:F6:EA:C5:60:AE:B1:5A:E8:26\",\"redirects\":3,\"retries\":5,\"fedid\":\"ukamf\"}},\"uri\":\"http://ukfederation.org.uk\",\"countries\":[\"GB\"],\"url\":\"http://www.ukfederation.org.uk/\",\"tags\":[],\"contact\":\"service@ukfederation.org.uk\",\"alt_ids\":{\"edugain\":\"UK-FEDERATION\",\"met\":\"uk-access-management-federation\"},\"descriptions\":{},\"displaynames\":{},\"policy\":\"http://www.ukfederation.org.uk/library/uploads/Documents/rules-of-membership.pdf\",\"logo\":\"https://www.ukfederation.org.uk/library/uploads/Documents/Logo2.jpg\",\"structure\":\"mesh\",\"interfederates\":[\"edugain\"],\"autotag\":false},\"incommon\":{\"id\":\"incommon\",\"name\":\"InCommon\",\"type\":\"nren\",\"protocols\":[\"saml2\"],\"sources\":{\"default\":{\"id\":\"default\",\"label\":\"default aggregate\",\"priority\":5,\"type\":\"aggregate\",\"strict\":false,\"cache\":true,\"auth\":null,\"url\":\"https://md.incommon.org/InCommon/InCommon-metadata.xml\",\"tags\":[],\"trustiness\":0.5,\"cert_url\":null,\"cert_fingerprint\":null,\"redirects\":3,\"retries\":5,\"fedid\":\"incommon\"},\"mdq\":{\"id\":\"mdq\",\"label\":\"mdq mdq\",\"priority\":5,\"type\":\"mdq\",\"strict\":false,\"cache\":true,\"auth\":null,\"url\":\"https://mdq.incommon.org\",\"tags\":[],\"trustiness\":0.5,\"cert_url\":\"http://md.incommon.org/certs/inc-md-cert-mdq.pem\",\"cert_fingerprint\":\"F8:4E:F8:47:EF:BB:EE:47:86:32:DB:94:17:8A:31:A6:94:73:19:36\",\"redirects\":3,\"retries\":5,\"fedid\":\"incommon\"}},\"uri\":\"https://incommon.org\",\"countries\":[\"US\"],\"url\":\"http://incommon.org/\",\"tags\":[],\"contact\":\"help@incommon.org\",\"alt_ids\":{\"edugain\":\"InCommon\",\"met\":\"incommon-federation\"},\"descriptions\":{},\"displaynames\":{},\"policy\":\"https://incommon.org/about/policies/\",\"logo\":\"https://incommon.org/wp-content/uploads/2019/08/Incommon2x.png\",\"structure\":\"mesh\",\"interfederates\":[\"edugain\"],\"autotag\":false}}"

      assert ^expected_json = content
    end

    @tag :tmp_dir
    test "The file can be parsed as JSON to return a map of federations", %{tmp_dir: tmp_dir} do

      filepath = "#{tmp_dir}/test.json"
      federations = SmeeFeds.federations([:ukamf, :incommon])
      assert :ok = Export.dd_json_file!(federations, filepath)

      assert Enum.all?(Map.values(SmeeFeds.Import.dd_json_file!(filepath)), fn v -> is_struct(v, Federation) end)
    end

  end

  ###

  describe "json!/1" do

    test "exports the specified federations as a JSON formatted string if passed a list of federations" do
      assert is_binary(Export.json!(SmeeFeds.federations([:ukamf, :incommon])))

      expected_json = "[{\"id\":\"ukamf\",\"name\":\"UK Access Management Federation\",\"type\":\"nren\",\"protocols\":[\"saml2\"],\"sources\":{\"default\":{\"id\":\"default\",\"label\":\"default aggregate\",\"priority\":5,\"type\":\"aggregate\",\"strict\":false,\"cache\":true,\"auth\":null,\"url\":\"http://metadata.ukfederation.org.uk/ukfederation-metadata.xml\",\"tags\":[],\"trustiness\":0.5,\"cert_url\":\"http://metadata.ukfederation.org.uk/ukfederation.pem\",\"cert_fingerprint\":\"AD:80:7A:6D:26:8C:59:01:55:47:8D:F1:BA:61:68:10:DA:81:86:66\",\"redirects\":3,\"retries\":5,\"fedid\":\"ukamf\"},\"mdq\":{\"id\":\"mdq\",\"label\":\"mdq mdq\",\"priority\":5,\"type\":\"mdq\",\"strict\":false,\"cache\":true,\"auth\":null,\"url\":\"http://mdq.ukfederation.org.uk/\",\"tags\":[],\"trustiness\":0.5,\"cert_url\":\"http://mdq.ukfederation.org.uk/ukfederation-mdq.pem\",\"cert_fingerprint\":\"3F:6B:F4:AF:E0:1B:3C:D7:C1:F2:3D:F6:EA:C5:60:AE:B1:5A:E8:26\",\"redirects\":3,\"retries\":5,\"fedid\":\"ukamf\"}},\"uri\":\"http://ukfederation.org.uk\",\"countries\":[\"GB\"],\"url\":\"http://www.ukfederation.org.uk/\",\"tags\":[],\"contact\":\"service@ukfederation.org.uk\",\"alt_ids\":{\"edugain\":\"UK-FEDERATION\",\"met\":\"uk-access-management-federation\"},\"descriptions\":{},\"displaynames\":{},\"policy\":\"http://www.ukfederation.org.uk/library/uploads/Documents/rules-of-membership.pdf\",\"logo\":\"https://www.ukfederation.org.uk/library/uploads/Documents/Logo2.jpg\",\"structure\":\"mesh\",\"interfederates\":[\"edugain\"],\"autotag\":false},{\"id\":\"incommon\",\"name\":\"InCommon\",\"type\":\"nren\",\"protocols\":[\"saml2\"],\"sources\":{\"default\":{\"id\":\"default\",\"label\":\"default aggregate\",\"priority\":5,\"type\":\"aggregate\",\"strict\":false,\"cache\":true,\"auth\":null,\"url\":\"https://md.incommon.org/InCommon/InCommon-metadata.xml\",\"tags\":[],\"trustiness\":0.5,\"cert_url\":null,\"cert_fingerprint\":null,\"redirects\":3,\"retries\":5,\"fedid\":\"incommon\"},\"mdq\":{\"id\":\"mdq\",\"label\":\"mdq mdq\",\"priority\":5,\"type\":\"mdq\",\"strict\":false,\"cache\":true,\"auth\":null,\"url\":\"https://mdq.incommon.org\",\"tags\":[],\"trustiness\":0.5,\"cert_url\":\"http://md.incommon.org/certs/inc-md-cert-mdq.pem\",\"cert_fingerprint\":\"F8:4E:F8:47:EF:BB:EE:47:86:32:DB:94:17:8A:31:A6:94:73:19:36\",\"redirects\":3,\"retries\":5,\"fedid\":\"incommon\"}},\"uri\":\"https://incommon.org\",\"countries\":[\"US\"],\"url\":\"http://incommon.org/\",\"tags\":[],\"contact\":\"help@incommon.org\",\"alt_ids\":{\"edugain\":\"InCommon\",\"met\":\"incommon-federation\"},\"descriptions\":{},\"displaynames\":{},\"policy\":\"https://incommon.org/about/policies/\",\"logo\":\"https://incommon.org/wp-content/uploads/2019/08/Incommon2x.png\",\"structure\":\"mesh\",\"interfederates\":[\"edugain\"],\"autotag\":false}]"
      assert ^expected_json = Export.json!(SmeeFeds.federations([:incommon, :ukamf]))
    end

    test "The string can be parsed as JSON to return a list of federations" do
      json_string = Export.json!(SmeeFeds.federations())
      assert Enum.all?(SmeeFeds.Import.json!(json_string), fn v -> is_struct(v, Federation) end)
    end

  end


  describe "json_file!/1" do

    @tag :tmp_dir
    test "writes the specified federations as a JSON formatted file if passed a path and list of federations, returning :ok", %{tmp_dir: tmp_dir} do

      filepath = "#{tmp_dir}/test.json"
      federations = SmeeFeds.federations([:ukamf, :incommon])
      assert :ok = Export.json_file!(federations, filepath)

      content = File.read!(filepath)
      assert is_binary(content)

      expected_json = "[{\"id\":\"ukamf\",\"name\":\"UK Access Management Federation\",\"type\":\"nren\",\"protocols\":[\"saml2\"],\"sources\":{\"default\":{\"id\":\"default\",\"label\":\"default aggregate\",\"priority\":5,\"type\":\"aggregate\",\"strict\":false,\"cache\":true,\"auth\":null,\"url\":\"http://metadata.ukfederation.org.uk/ukfederation-metadata.xml\",\"tags\":[],\"trustiness\":0.5,\"cert_url\":\"http://metadata.ukfederation.org.uk/ukfederation.pem\",\"cert_fingerprint\":\"AD:80:7A:6D:26:8C:59:01:55:47:8D:F1:BA:61:68:10:DA:81:86:66\",\"redirects\":3,\"retries\":5,\"fedid\":\"ukamf\"},\"mdq\":{\"id\":\"mdq\",\"label\":\"mdq mdq\",\"priority\":5,\"type\":\"mdq\",\"strict\":false,\"cache\":true,\"auth\":null,\"url\":\"http://mdq.ukfederation.org.uk/\",\"tags\":[],\"trustiness\":0.5,\"cert_url\":\"http://mdq.ukfederation.org.uk/ukfederation-mdq.pem\",\"cert_fingerprint\":\"3F:6B:F4:AF:E0:1B:3C:D7:C1:F2:3D:F6:EA:C5:60:AE:B1:5A:E8:26\",\"redirects\":3,\"retries\":5,\"fedid\":\"ukamf\"}},\"uri\":\"http://ukfederation.org.uk\",\"countries\":[\"GB\"],\"url\":\"http://www.ukfederation.org.uk/\",\"tags\":[],\"contact\":\"service@ukfederation.org.uk\",\"alt_ids\":{\"edugain\":\"UK-FEDERATION\",\"met\":\"uk-access-management-federation\"},\"descriptions\":{},\"displaynames\":{},\"policy\":\"http://www.ukfederation.org.uk/library/uploads/Documents/rules-of-membership.pdf\",\"logo\":\"https://www.ukfederation.org.uk/library/uploads/Documents/Logo2.jpg\",\"structure\":\"mesh\",\"interfederates\":[\"edugain\"],\"autotag\":false},{\"id\":\"incommon\",\"name\":\"InCommon\",\"type\":\"nren\",\"protocols\":[\"saml2\"],\"sources\":{\"default\":{\"id\":\"default\",\"label\":\"default aggregate\",\"priority\":5,\"type\":\"aggregate\",\"strict\":false,\"cache\":true,\"auth\":null,\"url\":\"https://md.incommon.org/InCommon/InCommon-metadata.xml\",\"tags\":[],\"trustiness\":0.5,\"cert_url\":null,\"cert_fingerprint\":null,\"redirects\":3,\"retries\":5,\"fedid\":\"incommon\"},\"mdq\":{\"id\":\"mdq\",\"label\":\"mdq mdq\",\"priority\":5,\"type\":\"mdq\",\"strict\":false,\"cache\":true,\"auth\":null,\"url\":\"https://mdq.incommon.org\",\"tags\":[],\"trustiness\":0.5,\"cert_url\":\"http://md.incommon.org/certs/inc-md-cert-mdq.pem\",\"cert_fingerprint\":\"F8:4E:F8:47:EF:BB:EE:47:86:32:DB:94:17:8A:31:A6:94:73:19:36\",\"redirects\":3,\"retries\":5,\"fedid\":\"incommon\"}},\"uri\":\"https://incommon.org\",\"countries\":[\"US\"],\"url\":\"http://incommon.org/\",\"tags\":[],\"contact\":\"help@incommon.org\",\"alt_ids\":{\"edugain\":\"InCommon\",\"met\":\"incommon-federation\"},\"descriptions\":{},\"displaynames\":{},\"policy\":\"https://incommon.org/about/policies/\",\"logo\":\"https://incommon.org/wp-content/uploads/2019/08/Incommon2x.png\",\"structure\":\"mesh\",\"interfederates\":[\"edugain\"],\"autotag\":false}]"
      assert ^expected_json = content
    end

    @tag :tmp_dir
    test "The file can be parsed as JSON to return a list of federations", %{tmp_dir: tmp_dir} do

      filepath = "#{tmp_dir}/test.json"
      federations = SmeeFeds.federations([:ukamf, :incommon])
      assert :ok = Export.json_file!(federations, filepath)

      assert Enum.all?(SmeeFeds.Import.json_file!(filepath), fn v -> is_struct(v, Federation) end)
    end

  end

end
