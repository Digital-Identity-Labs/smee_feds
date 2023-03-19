defmodule SmeeFeds.Federation do
  @moduledoc """
  Documentation for `SmeeFeds`.
  """
  alias SmeeFeds.Federation

  @enforce_keys [:id]

  defstruct [
    :id,
    :contact,
    :name,
    :url,
    countries: [],
    policy: nil,
    sources: %{}
  ]

  def new(id, data \\ []) do

    federation = %Federation{
      id: String.to_atom("#{id}"),
      contact: data[:contact],
      name: data[:name],
      url: data[:url],
      countries: normalize_country_codes(data),
      policy: data[:contact],
      sources: %{}
    }

    sources = (data[:metadata] || [])
              |> Enum.map(fn {id, data} -> {id, Smee.Source.new(data[:url], Map.to_list(data))} end)
              |> Enum.into(%{})

    struct(federation, %{sources: sources})

  end

  #  def find_by_country(country) do
  #
  #  end

  def contact(federation) do
    federation.contact
  end

  def sources(federation) do
    Map.get(federation, :sources, %{})
    |> Map.values()
  end

  def mdq(federation) do
    Map.get((federation.sources || %{}), :mdq)
  end

  def aggregate(federation) do
    Map.get((federation.sources || %{}), :default)
  end

  def url(federation) do
    federation.url
  end

  def policy_url(federation) do
    federation.policy
  end

  def countries(federation) do
    Map.get(federation, :countries, [])
    |> Enum.map(fn code -> Countries.get(code) end)
    |> ugh_brexit!()
  end

  #########

  defp normalize_country_codes(data) do
    Map.get(data, :countries, [])
    |> Enum.map(
         fn code -> "#{code}"
                    |> String.trim()
                    |> String.upcase()
         end
       )
  end

  defp ugh_brexit!(countries) do
    countries
    |> Enum.map(
         fn country ->
           if country.alpha2 == "GB", do: Map.merge(
             country,
             %{
               eea_member: false,
               eu_member: false
             }
           ),
                                      else: country

         end
       )
  end

end
