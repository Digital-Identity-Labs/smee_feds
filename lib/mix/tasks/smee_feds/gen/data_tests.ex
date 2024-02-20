defmodule Mix.Tasks.SmeeFeds.Gen.DataTests do
  @moduledoc "Create a new set of compatibility tests, overwriting the existing set"
  @shortdoc "Create a new set of compatibility tests"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do

    IO.puts "Building basic compatibility test files..."

    SmeeFeds.federations()
    |> Enum.each(
         fn federation ->

           fed_id = "#{federation.id}"
           module_name = "Data#{String.capitalize(fed_id)}Test"
           filename = "test/data/data_#{fed_id}_test.exs"

           # dam = SmeeFeds.Federation.aggregate(federation)
           # mdq = SmeeFeds.Federation.mdq(federation)

           contents = """
             defmodule #{module_name} do
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
                 test "can download the metadata from #{fed_id}" do

                  url = SmeeFeds.federation(:#{fed_id})
                         |> Federation.aggregate()
                         |> Map.get(:url)

                      response = Req.get!(url)

                      assert %{status: 200} = response

                 end

               end

             end

           """

           if File.exists?(filename) && String.contains?(File.read!(filename), "@protected") do
             IO.puts "Skipping #{filename} as it is marked as @protected"
           else
             IO.puts "Creating/overwriting #{filename}..."
             File.write!(filename, contents)
           end

         end
       )

  end
end
