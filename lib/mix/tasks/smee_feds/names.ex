defmodule Mix.Tasks.SmeeFeds.Names do
  @moduledoc "List general info for default federations"
  @shortdoc "List general info for default federations"

  use Mix.Task

  alias SmeeFeds.Federation
  alias Smee.Source

  @impl Mix.Task
  def run(_args) do

    rows = SmeeFeds.federations()
           |> Enum.map(fn f -> {f, Federation.aggregate(f)} end)
           |> Enum.reject(fn {f, s} -> is_nil(s) end)
           |> Enum.map(
                fn {f, s} ->
                  [
                    Federation.id(f),
                    f.name,
                    Enum.join(f.countries, " "),
                    Enum.join(f.tags, " "),
                  ]
                end
              )

    title = "SmeeFeds Default Federation General Info"
    header = ["SmeeFedsID", "Name", "Countries", "Tags"]


    TableRex.quick_render!(rows, header, title)
    |> IO.puts

  end
end
