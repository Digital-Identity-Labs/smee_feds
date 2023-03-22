defmodule SmeeFeds.Export do

  @moduledoc """

  """

  alias SmeeFeds.Federation
  alias Smee.Source
  alias Countries.Country

  def csv(federations \\ SmeeFeds.federations()) do
    Enum.map(
      federations,
      fn f ->
        [
          f.id,
          f.name,
          f.url,
          f.countries,
          f.policy,
          f.contact,
          ems(Federation.aggregate(f)),
          ems(Federation.mdq(f)),
        ]
      end
    )
    |> CSV.encode()
    |> Enum.join("")
  end

  def markdown(federations \\ SmeeFeds.federations()) do
    top = """
    | ID | Name | URL | Countries | Policy URL | Contact | Aggregate URL | MDQ URL |
    |----|-----|-----|-----------|--------|---------|-----------|-----|
    """

    rows = Enum.map(
      federations,
      fn f ->
        [
          "",
          emt(f.id),
          emt(f.name),
          emt(f.url),
          emc(f.countries),
          emt(f.policy),
          emt(f.contact),
          ems(Federation.aggregate(f)),
          ems(Federation.mdq(f)),
          ""
        ]
        |> Enum.join("| ")
      end
    )

    Enum.join([String.trim(top)] ++ rows, "\n")

  end

  def json(federations \\ SmeeFeds.federations()) do
    Enum.map(
      federations,
      fn f ->
        {
          f.id,
          %{
            "name": f.name,
            "url": f.url,
            "countries": f.countries,
            "policy": f.policy,
            "contact": f.contact,
            "sources": jsources(f.sources)
          }
          |> purge_nulls()
        }
      end
    )
    |> Enum.into(%{})
    |> Jason.encode!()
  end

  #############################################################################

  defp purge_nulls(map) do
    map
    |> Enum.filter(fn {_key, value} -> !is_nil(value) end)
    |> Map.new()
  end

  defp emt(text) do
    "#{text}"
    |> String.replace("|", "")
  end

  defp emc(countries) do
    countries
    |> Enum.map(fn c -> String.downcase(emt(c)) end)
    |> Enum.join(", ")
  end

  defp jsources(sources) do
    sources
    |> Enum.map(
         fn {id, source} ->
           {
             "#{id}",
             %{
               "url": source.url,
               "cert_url": source.cert_url,
               "cert_fp": source.cert_fingerprint,
               "type": jstype(source)
             }
             |> purge_nulls()
           }
         end
       )
    |> Enum.into(%{})
  end

  defp jstype(source) do
    case source.type do
      "" -> "aggregate"
      nil -> "aggregate"
      other -> "#{other}"
    end
  end

  defp ems(source) do
    case source do
      nil -> ""
      %Source{url: url} -> url
    end
  end

end
