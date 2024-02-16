defmodule Mix.Tasks.SmeeFeds.Ids do
  @moduledoc "List Ids used by default federations"
  @shortdoc "List Ids used by default federations"

  use Mix.Task

  #alias Mix.Shell.IO
  alias SmeeFeds.Federation

  @manual_text """
  This task will produce a table of identifiers for all default federation records
  """

  @impl Mix.Task
  def run(_args) do

  rows = SmeeFeds.federations
  |> Enum.map(fn f -> [Federation.id(f), Federation.id(f, :uri), Federation.id(f, :edugain), Federation.id(f, :met)] end)

  title = "SmeeFeds Default Federation IDs"
  header = ["SmeeFeds ID", "URI", "Edugain ID", "MET ID"]


  TableRex.quick_render!(rows, header, title)
  |> IO.puts

  end
end
