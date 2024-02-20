defmodule Mix.Tasks.SmeeFeds.Data.Mdq do
  @moduledoc "List MDQ service sources used by default federations"
  @shortdoc "List MDQ services used by default federations"

  use Mix.Task

  alias SmeeFeds.Federation
  alias Smee.Source

  @impl Mix.Task
  def run(_args) do

    rows = SmeeFeds.federations()
           |> Enum.map(fn f -> {f, Federation.mdq(f)} end)
           |> Enum.reject(fn {f, s} -> is_nil(s) end)
           |> Enum.map(
                fn {f, s} -> [Federation.id(f), s.url, s.cert_url, s.cert_fingerprint]
                end
              )

    title = "SmeeFeds Default Federation Aggregate Metadata Sources"
    header = ["SmeeFeds ID", "URL", "Cert URL", "Cert FP"]


    TableRex.quick_render!(rows, header, title)
    |> IO.puts

  end
end
