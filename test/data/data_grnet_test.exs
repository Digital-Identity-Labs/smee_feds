  defmodule DataGrnetTest do
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
     test "URL for grnet aggregate responds to requests" do
       url = SmeeFeds.federation(:grnet)
              |> Federation.aggregate()
              |> Map.get(:url)

        assert Audit.resource_present?(url)
      end

     @tag timeout: 440_000
      test "can download the metadata from grnet" do

       md = SmeeFeds.federation(:grnet)
              |> Federation.aggregate()
              |> Smee.fetch!()

           assert %Smee.Metadata{} = md

      end

    end

  end

