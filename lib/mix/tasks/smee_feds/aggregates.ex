defmodule Mix.Tasks.SmeeFeds.Aggregates do
  @moduledoc "List metadata sources used by default federations"
  @shortdoc "List metadata used by default federations"

  use Mix.Task

  alias SmeeFeds.Federation
  alias Smee.Source

  @impl Mix.Task
  def run(_args) do

    rows = SmeeFeds.federations()
           |> Enum.map(fn f -> {f, Federation.aggregate(f)} end)
           |> Enum.reject(fn {f, s} -> is_nil(s) end)
           |> Enum.map(
                fn {f, s} -> ["#{Federation.id(f)}:#{s.id}", s.url, s.cert_url, s.cert_fingerprint]
                end
              )

    title = "SmeeFeds Default Federation Aggregate Metadata Sources"
    header = ["SmeeFedsID", "SourceID", "URL", "Cert URL", "Cert FP"]


    TableRex.quick_render!(rows, header, title)
    |> IO.puts

  end
end
