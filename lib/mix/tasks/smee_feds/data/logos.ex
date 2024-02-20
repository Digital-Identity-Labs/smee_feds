defmodule Mix.Tasks.SmeeFeds.Data.Logos do
  @moduledoc "List logos of default federations"
  @shortdoc "List logos of default federations"

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
                    f.logo,
                  "?"
                  ]
                end
              )

    title = "SmeeFeds Default Federation Technical details"
    header = ["SmeeFedsID", "Logo URL", "Present?"]


    TableRex.quick_render!(rows, header, title)
    |> IO.puts

  end
end
