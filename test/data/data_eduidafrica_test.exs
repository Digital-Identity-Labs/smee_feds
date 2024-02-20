  defmodule DataEduidafricaTest do
    use ExUnit.Case, async: false

    @moduletag :data

    alias SmeeFeds
    alias SmeeFeds.Federation
    #alias Smee.Metadata
    #alias Smee.Security
    #alias Smee.MDQ
    #alias Smee.Fetch

    describe "default aggregate metadata url" do

      @tag timeout: 360_000
      test "can download the metadata from eduidafrica" do

       url = SmeeFeds.federation(:eduidafrica)
              |> Federation.aggregate()
              |> Map.get(:url)

           response = Req.get!(url)

           assert %{status: 200} = response

      end

    end

  end

