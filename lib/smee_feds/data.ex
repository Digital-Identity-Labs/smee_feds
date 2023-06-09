defmodule SmeeFeds.Data do
  @moduledoc false

  alias SmeeFeds.Federation

  @federations SmeeFeds.DataLoader.load()
               |> Enum.reject(
                    fn
                      {_id, %{active: active}} -> active == false
                      {_, _} -> false
                    end
                  )
               |> Enum.map(
                    fn {id, data} ->
                      {
                        id,
                        Federation.new(
                          id,
                          contact: data[:contact],
                          name: data[:name],
                          url: data[:url],
                          uri: data[:uri],
                          countries: data[:countries],
                          policy: data[:policy],
                          sources: data[:sources]
                        )
                      }
                    end
                  )
               |> Enum.into(%{})

  @spec federations() :: map()
  def federations do
    if production_environment?(), do: IO.warn "Please do not use the default SmeeFeds database in production", []
    @federations
  end

  #############################################################################
  @spec production_environment?() :: boolean()
  defp production_environment? do

    cond do
      function_exported?(Mix, :env, 0) && apply(Mix, :env, []) == :prod -> true
      System.get_env("MIX_ENV") == "prod" -> true
      function_exported?(Mix, :env, 0) && apply(Mix, :env, []) == :test -> false
      function_exported?(Mix, :env, 0) && apply(Mix, :env, []) == :dev -> false
      System.get_env("MIX_ENV") == "test" -> false
      System.get_env("MIX_ENV") == "dev" -> false
      true -> true
    end



  end

end
