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
      countries: normalize_country_codes(data[:countries]),
      policy: data[:contact],
      sources: %{}
    }

    sources = (data[:sources] || %{})
              |> Enum.map(
                   fn {id, data} -> {id, Smee.Source.new(data[:url], normalize_source_options(federation, data))} end
                 )
              |> Enum.into(%{})

    struct(federation, %{sources: sources})

  end

  def contact(federation) do
    federation.contact
  end

  def sources(federation) do
    Map.get(federation, :sources, %{})
    |> Map.values()
  end

  def mdq(%Federation{sources: nil}) do
    nil
  end

  def mdq(
        %Federation{
          sources: %{
            mdq: mdq
          }
        }
      ) do
    mdq
  end

  def mdq(%Federation{sources: sources}) when is_map(sources) do
    Enum.find(sources, fn {id, source} -> source.type == :mdq end)
    |> case() do
         {_id, source} -> source
         nil -> nil
       end
  end

  def aggregate(%Federation{sources: nil}) do
    nil
  end

  def aggregate(
        %Federation{
          sources: %{
            default: default
          }
        }
      ) do
    default
  end

  def aggregate(%Federation{sources: sources}) when is_map(sources) do
    Enum.find(sources, fn {id, source} -> source.type == :aggregate end)
    |> case() do
         {_id, source} -> source
         nil -> nil
       end
  end

  def url(federation) do
    federation.url
  end

  def policy_url(federation) do
    federation.policy
  end

  def countries(%Federation{countries: trouble}) when is_nil(trouble) or trouble == []  do
    []
  end

  def countries(federation) do
    Map.get(federation, :countries, [])
    |> Enum.map(fn code -> Countries.get(code) end)
    |> ugh_brexit!()
  end

  #############################################################################

  defp normalize_source_options(federation, data) do
    [
      type: String.to_atom("#{data[:type]}"),
      cert_url: data[:cert_url],
      cert_fingerprint: data[:cert_fp],
      label: "#{federation.name}: #{data[:type]}"
    ]
  end

  defp normalize_country_codes(countries_list) when is_nil(countries_list) or countries_list == [] do
    []
  end

  defp normalize_country_codes(countries_list) do
    countries_list
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
