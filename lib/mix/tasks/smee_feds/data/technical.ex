defmodule Mix.Tasks.SmeeFeds.Data.Technical do
  @moduledoc "List technical details of default federations"
  @shortdoc "List technical details of default federations"

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
                    f.type,
                    f.structure,
                    f.protocols,
                    Enum.join(
                      [
                        if(Federation.aggregate(f), do: "aggregate", else: ""),
                        (if Federation.mdq(f), do: "mdq", else: "")
                      ],
                      " "
                    )
                  ]
                end
              )

    title = "SmeeFeds Default Federation Technical details"
    header = ["SmeeFedsID", "Type", "Structure", "Protocols", "Services"]


    TableRex.quick_render!(rows, header, title)
    |> IO.puts

  end
end
