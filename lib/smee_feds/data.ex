defmodule SmeeFeds.Data do
  @moduledoc """
  Documentation for `SmeeFeds`.
  """

  @federations SmeeFeds.DataLoader.load()
               |> Enum.map(fn {id, data} -> {id, SmeeFeds.Federation.new(id, data)} end)
               |> Enum.into(%{})

  def federations do
    @federations
  end

end
