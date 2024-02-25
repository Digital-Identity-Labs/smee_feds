defmodule SmeeFeds.Export do

  @moduledoc """
  Converts lists of federations into other formats suitable for export and use in other applications.

  Some exports are focused on presenting the data (such as `markdown/1`, others are lossy summaries (`csv/1`) and some are
    contain all data (`json/1`).
  """

  alias SmeeFeds.Federation
  alias Smee.Source

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
  Produces a string containing all passed federations in the JSON format used for SmeeFeds default data.

  This format is best used for creating new default data sets, and is not for general purpose serialization.

  It is possible to use additional lines in federation records:

   * `active: false` - prevents the record from loading
   * `comment: "a comment"` - notes that will be ignored when the data is loaded
   * `todo: "task details"` - developer notes that will be ignored when the data is loaded

  The JSON *should* contain all federation information and can be used by SmeeFeds as a replacement for the default source of
  federation information. Federations are stored in a map.
  """
  @spec dd_json!(federations :: list(Federation.t())) :: binary()
  def dd_json!(federations) do
    Enum.map(
      federations,
      fn f ->
        {
          f.id,
          f
        }
      end
    )
    |> Enum.into(%{})
    |> Jason.encode!()
  end

  @doc """
  Produces a string containing all passed federations in the JSON format used for SmeeFeds default data,
    and then writes it directly to disk at the specified filename/path.

  This format is best used for creating new default data sets, and is not for general purpose serialization.

  It is possible to use additional lines in federation records:

   * `active: false` - prevents the record from loading
   * `comment: "a comment"` - notes that will be ignored when the data is loaded
   * `todo: "task details"` - developer notes that will be ignored when the data is loaded

  The JSON *should* contain all federation information and can be used by SmeeFeds as a replacement for the default source of
  federation information. Federations are stored in a map.
  """
  @spec dd_json_file!(federations :: list(Federation.t()), path :: binary()) :: :ok
  def dd_json_file!(federations, path) do
    File.write!(path, dd_json!(federations))
  end

  @doc """
  Produces a string containing all passed federations in the normal Smee JSON format.

  This format is best for general-purpose serialisation of the federation records.

  Federations are stored as a list.
  """
  @spec json!(federations :: list(Federation.t())) :: binary()
  def json!(federations) do
    Jason.encode!(federations)
  end

  @doc """
  Creates a file containing all passed federations in the normal Smee JSON format.

  This format is best for general-purpose serialisation of the federation records.

  Federations are stored as a list.
  """
  @spec json_file!(federations :: list(Federation.t()), path :: binary()) :: :ok
  def json_file!(federations, path) do
    File.write!(path, json!(federations))
  end

  #############################################################################

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

  @spec ems(source :: nil | map()) :: binary()
  defp ems(source) do
    case source do
      nil -> ""
      %Source{url: url} -> url
    end
  end

end
