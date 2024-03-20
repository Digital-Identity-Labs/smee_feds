  defmodule DataAafTest do
    use ExUnit.Case, async: false

    @moduletag :data

    alias SmeeFeds
    alias SmeeFeds.Federation
    alias SmeeFeds.Audit
    #alias Smee.Metadata
    #alias Smee.Security
    #alias Smee.MDQ
    #alias Smee.Fetch

    describe "default aggregate metadata url" do

     @tag timeout: 30_000
     test "URL for aaf aggregate responds to requests" do
       url = SmeeFeds.federation(:aaf)
              |> Federation.aggregate()
              |> Map.get(:url)

        assert Audit.resource_present?(url)
      end

     @tag timeout: 440_000
      test "can download the metadata from aaf" do

       md = SmeeFeds.federation(:aaf)
              |> Federation.aggregate()
              |> Smee.fetch!()

           assert %Smee.Metadata{} = md

      end

    end

  end

