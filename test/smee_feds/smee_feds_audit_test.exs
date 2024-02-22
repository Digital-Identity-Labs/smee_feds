defmodule SmeeFedsUtilsTest do
  use ExUnit.Case

  alias SmeeFeds.Audit

  describe "resource_present?/1" do

   test "returns true if a URL returns a 200 status" do
    assert Audit.resource_present?("https://www.mimoto.co.uk")
   end

   test "returns false if a URL returns a non-200 status" do
     refute Audit.resource_present?("https://digitalidentitylabs.com/sf_missing_page_test")
   end

   test "returns false if a URL can't even be accessed" do
     refute Audit.resource_present?("bad_example")
   end

  end

end
