# Run from project base directory!

Mix.install(
  [
    {:rambo, "> 0.0.0"},
    {:smee_feds, "> 0.0.0", path: "."},
  ]
)

IO.puts "Building basic compatibility test files"

SmeeFeds.federations()
|> Enum.each(
     fn federation ->

       fed_id = "#{federation.id}"
       module_name = "Data#{String.capitalize(fed_id)}Test"
       filename = "test/data/data_#{fed_id}_test.exs"

       dam = SmeeFeds.Federation.aggregate(federation)
       mdq = SmeeFeds.Federation.mdq(federation)

       contents = """
         defmodule #{module_name} do
           use ExUnit.Case

           @moduletag :data

           alias SmeeFeds
           alias SmeeFeds.Federation
           #alias Smee.Metadata
           #alias Smee.Security
           #alias Smee.MDQ
           #alias Smee.Fetch

           describe "default aggregate metadata url" do

             test "can download the metadata from #{fed_id}" do

              url = SmeeFeds.get(:#{fed_id})
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
