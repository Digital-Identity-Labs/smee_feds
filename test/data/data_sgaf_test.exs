  defmodule DataSgafTest do
    use ExUnit.Case

    @moduletag :data

    alias SmeeFeds
    alias SmeeFeds.Federation
    #alias Smee.Metadata
    #alias Smee.Security
    #alias Smee.MDQ
    #alias Smee.Fetch

    describe "default aggregate metadata url" do

      test "can download the metadata from sgaf" do

       url = SmeeFeds.get(:sgaf)
              |> Federation.aggregate()
              |> Map.get(:url)

           response = Req.get!(url)

           assert %{status: 200} = response

      end

    end

  end

