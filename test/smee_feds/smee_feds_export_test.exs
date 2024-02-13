defmodule SmeeFedsExportTest do
  use ExUnit.Case

  alias SmeeFeds.Export

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
                 "mailto:support@aaf.edu.au",
                 "https://md.aaf.edu.au/aaf-metadata.xml",
                 ""
               ],
               [
                 "aaieduhr",
                 "AAI@EduHr",
                 "http://www.aaiedu.hr/",
                 "HR",
                 "http://www.aaiedu.hr/docs/AAI@EduHr-pravilnik-ver1.3.1.pdf",
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
                          | ID | Name | URL | Countries | Policy URL | Contact | Aggregate URL | MDQ URL |\n|----|-----|-----|-----------|--------|---------|-----------|-----|\n| ukamf| UK Access Management Federation| http://www.ukfederation.org.uk/| gb| http://www.ukfederation.org.uk/library/uploads/Documents/rules-of-membership.pdf| mailto:service@ukfederation.org.uk| http://metadata.ukfederation.org.uk/ukfederation-metadata.xml| http://mdq.ukfederation.org.uk/| \n| incommon| InCommon| http://incommon.org/| us| https://incommon.org/about/policies/| mailto:help@incommon.org| https://md.incommon.org/InCommon/InCommon-metadata.xml| https://mdq.incommon.org|
                          """
                          |> String.trim()
      assert ^expected_markdown = String.trim(markdown)
    end

  end

  describe "json/1" do

    test "exports all default federations as a JSON formatted string if not passed a list of federations" do
      assert is_binary(Export.json())
    end

    test "exports the specified federations as a JSON formatted string if passed a list of federations" do
      assert is_binary(Export.json(SmeeFeds.federations([:ukamf, :incommon])))

      expected_json = "{\"ukamf\":{\"name\":\"UK Access Management Federation\",\"sources\":{\"default\":{\"type\":\"aggregate\",\"url\":\"http://metadata.ukfederation.org.uk/ukfederation-metadata.xml\",\"cert_url\":\"http://metadata.ukfederation.org.uk/ukfederation.pem\",\"cert_fp\":\"AD:80:7A:6D:26:8C:59:01:55:47:8D:F1:BA:61:68:10:DA:81:86:66\"},\"mdq\":{\"type\":\"mdq\",\"url\":\"http://mdq.ukfederation.org.uk/\",\"cert_url\":\"http://mdq.ukfederation.org.uk/ukfederation-mdq.pem\",\"cert_fp\":\"3F:6B:F4:AF:E0:1B:3C:D7:C1:F2:3D:F6:EA:C5:60:AE:B1:5A:E8:26\"}},\"countries\":[\"GB\"],\"url\":\"http://www.ukfederation.org.uk/\",\"policy\":\"http://www.ukfederation.org.uk/library/uploads/Documents/rules-of-membership.pdf\",\"contact\":\"mailto:service@ukfederation.org.uk\"},\"incommon\":{\"name\":\"InCommon\",\"sources\":{\"default\":{\"type\":\"aggregate\",\"url\":\"https://md.incommon.org/InCommon/InCommon-metadata.xml\"},\"mdq\":{\"type\":\"mdq\",\"url\":\"https://mdq.incommon.org\",\"cert_url\":\"http://md.incommon.org/certs/inc-md-cert-mdq.pem\",\"cert_fp\":\"F8:4E:F8:47:EF:BB:EE:47:86:32:DB:94:17:8A:31:A6:94:73:19:36\"}},\"countries\":[\"US\"],\"url\":\"http://incommon.org/\",\"policy\":\"https://incommon.org/about/policies/\",\"contact\":\"mailto:help@incommon.org\"}}"

      assert ^expected_json = Export.json(SmeeFeds.federations([:incommon, :ukamf]))
    end

  end

end
