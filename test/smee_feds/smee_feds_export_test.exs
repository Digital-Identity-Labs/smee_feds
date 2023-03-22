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
                 "mailto:support@aaf.edu.au",
                 "mailto:support@aaf.edu.au",
                 "https://md.aaf.edu.au/aaf-metadata.xml",
                 ""
               ],
               [
                 "aaieduhr",
                 "AAI@EduHr",
                 "http://www.aaiedu.hr/",
                 "HR",
                 "mailto:team@aaiedu.hr",
                 "mailto:team@aaiedu.hr",
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

      expected_markdown = """
      | ID | Name | URL | Countries | Policy URL | Contact | Aggregate URL | MDQ URL |
      |----|-----|-----|-----------|--------|---------|-----------|-----|
      | ukamf| UK Access Management Federation| http://www.ukfederation.org.uk/| gb| mailto:service@ukfederation.org.uk| mailto:service@ukfederation.org.uk| http://metadata.ukfederation.org.uk/ukfederation-metadata.xml| http://mdq.ukfederation.org.uk/|
      | incommon| InCommon| http://incommon.org/| us| mailto:help@incommon.org| mailto:help@incommon.org| https://md.incommon.org/InCommon/InCommon-metadata.xml| https://mdq.incommon.org|
      """
      assert expected_markdown = markdown
    end

  end

  describe "json/1" do

    test "exports all default federations as a JSON formatted string if not passed a list of federations" do
      assert is_binary(Export.json())
    end

    test "exports the specified federations as a JSON formatted string if passed a list of federations" do
      assert is_binary(Export.json(SmeeFeds.federations([:ukamf, :incommon])))

      expected_json = "{\"incommon\":{\"contact\":\"mailto:help@incommon.org\",\"countries\":[\"US\"],\"name\":\"InCommon\",\"policy\":\"mailto:help@incommon.org\",\"sources\":{\"default\":{\"type\":\"aggregate\",\"url\":\"https://md.incommon.org/InCommon/InCommon-metadata.xml\"},\"mdq\":{\"cert_fp\":\"F8:4E:F8:47:EF:BB:EE:47:86:32:DB:94:17:8A:31:A6:94:73:19:36\",\"cert_url\":\"http://md.incommon.org/certs/inc-md-cert-mdq.pem\",\"type\":\"aggregate\",\"url\":\"https://mdq.incommon.org\"}},\"url\":\"http://incommon.org/\"},\"ukamf\":{\"contact\":\"mailto:service@ukfederation.org.uk\",\"countries\":[\"GB\"],\"name\":\"UK Access Management Federation\",\"policy\":\"mailto:service@ukfederation.org.uk\",\"sources\":{\"default\":{\"cert_fp\":\"AD:80:7A:6D:26:8C:59:01:55:47:8D:F1:BA:61:68:10:DA:81:86:66\",\"cert_url\":\"http://metadata.ukfederation.org.uk/ukfederation.pem\",\"type\":\"aggregate\",\"url\":\"http://metadata.ukfederation.org.uk/ukfederation-metadata.xml\"},\"mdq\":{\"cert_fp\":\"3F:6B:F4:AF:E0:1B:3C:D7:C1:F2:3D:F6:EA:C5:60:AE:B1:5A:E8:26\",\"cert_url\":\"http://mdq.ukfederation.org.uk/ukfederation-mdq.pem\",\"type\":\"mdq\",\"url\":\"http://mdq.ukfederation.org.uk/\"}},\"url\":\"http://www.ukfederation.org.uk/\"}}"

      assert expected_json = Export.json(SmeeFeds.federations([:ukamf, :incommon]))
    end

  end

end
