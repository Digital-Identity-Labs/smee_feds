defmodule SmeeFeds.Export do

  @moduledoc """
  Converts lists of federations into other formats suitable for export and use in other applications.

  Some exports are focused on presenting the data (such as `markdown/1`, others are lossy summaries (`csv/1`) and some are
    contain all data (`json/1`).
  """

  alias SmeeFeds.Federation
  alias Smee.Source
  alias Countries.Country

  @doc """
  Creates a CSV export of the provided federations as a single string.

  Not all information is included - the CSV only contains ID, name, URL, countries, policy url and metadata URLs for the
    main aggregate and MDQ service. Other information is not included.
  """
  @spec csv(federations :: list(Federation.t())) :: binary()
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

  @doc """
  Produces a simple Markdown-formatted table summarising the provided list of federations.

    Not all information is included - the CSV only contains ID, name, URL, countries, policy url and metadata URLs for the
    main aggregate and MDQ service. Other information is not included.

  The Markdown output can be used with most modern markdown parsers, including Github comments.
  """
  @spec markdown(federations :: list(Federation.t())) :: binary()
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

  @doc """
  Produces a string containing all passed federations (or default set) in JSON format.

  The JSON *should* contain all federation information and can be used by SmeeFeds as a replacement for the default source of
  federation information.
  """
  @spec json(federations :: list(Federation.t())) :: binary()
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

  @spec purge_nulls(map :: map()) :: map()
  defp purge_nulls(map) do
    map
    |> Enum.filter(fn {_key, value} -> !is_nil(value) end)
    |> Map.new()
  end

  @spec emt(text :: binary() | atom()) :: binary()
  defp emt(text) do
    "#{text}"
    |> String.replace("|", "")
  end

  @spec emc(countries :: list(binary())) :: binary()
  defp emc(countries) do
    countries
    |> Enum.map_join(", ", fn c -> String.downcase(emt(c)) end)
    #    |> Enum.map(fn c -> String.downcase(emt(c)) end)
    #    |> Enum.join(", ")
  end

  @spec jsources(sources :: map()) :: map()
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

  @spec jstype(source :: map()) :: binary()
  defp jstype(source) do
    case source.type do
      "" -> "aggregate"
      nil -> "aggregate"
      other -> "#{other}"
    end
  end

  @spec ems(source :: nil | map()) :: binary()
  defp ems(source) do
    case source do
      nil -> ""
      %Source{url: url} -> url
    end
  end

end
