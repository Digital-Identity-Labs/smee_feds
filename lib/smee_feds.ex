defmodule SmeeFeds do
  @moduledoc """
  `SmeeFeds` is a small federation management extension to [Smee](https://github.com/Digital-Identity-Labs/smee) for use
  in research, testing and development.

  [Smee](https://github.com/Digital-Identity-Labs/smee) has tools for handling the sources of SAML metadata but
  nothing to represent the publishers of metadata. SmeeFeds adds a few tools for handling federations and includes a large
  collection of information about research and education federations.

  ## Features

  * Easily find information about major federations
  * Filter and group federations by location or EU membership
  * Use federation records directly with Smee to download metadata from aggregates or MDQ servers
  * Export lists of federation information as CSV, JSON or Markdown documents

  The top level `SmeeFeds` module has tools for selecting individual federation details or lists of many at once.
  SmeeFeds contain more tools for handling federations, such as:

  * `SmeeFeds.Federation` - tools for accessing data such as metadata download URLs, contacts, homepages, and so on.
  * `SmeeFeds.Export` - convert lists of federations into data for export, or simple text reports
  * `SmeeFeds.Filter` - filter lists of federations by various criteria

  ## IMPORTANT DISCLAIMER AND WARNING

  SmeeFeds comes with a built-in list of federations, using information gathered from various sources on the Internet.

  This collection of information is for use by **researchers, developers and testers**.

  **IT IS NOT FOR USE IN PRODUCTION ENVIRONMENTS**

  Metadata is the bedrock of trust and information security in SAML federations. DO NOT use metadata URLs, certificates
  and certificate fingerprints to download and use metadata in live services without confirming each detail yourself.

  If you must use SmeeFeds as part of a production service, then after information has been verified you can export only
  the verified information you need as a JSON file and set it as the new default using
  `:smee_feds, :data_file` config setting in your application.

  There is absolutely no guarantee or warranty that the data in SmeeFeds is correct, and it is not supported by any of
  the federations listed. It's totally unofficial.
  """

  alias SmeeFeds.Federation
  alias SmeeFeds.DefaultData
  alias Smee.Metadata
  alias Smee.Entity
  alias Smee.Source

  @doc """
  Returns the ids of all federations in the default collection as a list of atoms.

  ## Example

      iex> ids = SmeeFeds.ids()
  """
  @spec ids(federations :: list() | nil) :: list(atom())
  def ids() do
    DefaultData.federations()
    |> Map.keys()
  end

  @doc """
  Returns the ids of all federations in the provided list of federations as a list of atoms.

  ## Example

       iex> federations = SmeeFeds.federations([:ukamf, :ref])
       iex> ids = SmeeFeds.ids(federations)
  """
  def ids(federations) do
    federations
    |> Enum.map(fn f -> f.id end)
  end

  @doc """
  Returns a list of `SmeeFeds.Federation` structs when passed a list of
   federation IDs (as atoms).

  ## Example

      iex> federations = SmeeFeds.federations([:ukamf, :ref])
  """
  @spec federations(federations :: list()) :: list(Federation.t())
  def federations(federations) when is_list(federations) do
    federations
    |> Enum.map(
         fn
           %Federation{} = f -> f
           id -> get(id)
         end
       )
    |> Enum.reject(fn v -> is_nil(v) end)
  end

  @doc """
  Returns a list of `SmeeFeds.Federation` structs.

  Returns all known federations from the default collection.

  ## Example
      iex> federations = SmeeFeds.federations()
  """
  @spec federations() :: list(Federation.t())
  def federations() do
    DefaultData.federations()
    |> Map.values()
  end

  @doc """
  Finds a federation in the default database by ID and returns the full federation record.

  ## Example
      iex> incommon = SmeeFeds.federation(:incommon)
  """
  @spec federation(federation :: atom() | binary()) :: Federation.t() | nil
  def federation(id) do
    get(id)
  end

  @doc """
  Finds a federation in the default database by ID and returns the full federation record.

  ## Example
      iex> incommon = SmeeFeds.get(:incommon)
  """
  @spec get(federation :: atom() | binary()) :: Federation.t() | nil
  def get(id) when is_binary(id) do
    try do
      String.to_existing_atom(id)
      |> get()
    rescue
      _ -> nil
    end

  end

  def get(id) do
    DefaultData.federations()
    |> Map.get(id)
  end

  @doc """
  Tries to find the federation that published the provided Smee record (source, entity or metadata)

  The first matching federation record will be returned if found, or nil if no federations match.

  ## Example

      iex> source = Smee.source("http://metadata.ukfederation.org.uk/ukfederation-metadata.xml")
      iex> federation = SmeeFeds.publisher(source)
      %SmeeFeds.Federation{id: :ukamf} = federation

  """
  @spec publisher(smee_struct :: Source.t() | Metadata.t() | Entity.t()) :: Federation.t() | nil
  def publisher(smee_struct, federations \\ federations()) do
    federations
    |> Enum.find(fn federation -> publisher?(federation, smee_struct)  end)
  end

  @doc """
  Is a federation the publisher of the provided Smee Source, Metadata, or Entity?

  Returns true if the federation and source, metadata or entity share a URL or publisher URI, false otherwise.

  ## Example

      iex> source = Smee.source("http://metadata.ukfederation.org.uk/ukfederation-metadata.xml")
      iex> federation = SmeeFeds.get(:ukamf)
      iex> SmeeFeds.publisher?(federation, source)
      true

  """
  @spec publisher?(Federation.t(), smee_struct :: Source.t() | Metadata.t() | Entity.t()) :: boolean()
  def publisher?(federation, %Metadata{uri: uri, url: url}) do
    cond do
      uri == federation.uri -> true
      Enum.any?(Federation.sources(federation), fn s -> s.url == url end) -> true
      true -> false
    end
  end

  def publisher?(federation, %Entity{metadata_uri: uri}) do
    cond do
      uri == federation.uri -> true
      true -> false
    end
  end

  def publisher?(federation, %Source{url: url}) do
    cond do
      Enum.any?(Federation.sources(federation), fn s -> s.url == url end) -> true
      true -> false
    end
  end

  @doc """
  Lists all countries in the provided list of federations (or the default set if no federations are passed)

  ## Examples

      iex> SmeeFeds.countries()
      iex> SmeeFeds.federations([:ukamf, :incommon]) |> SmeeFeds.countries()

  """
  @spec countries(list(Federation.t())) :: list(struct())
  def countries(federations \\ federations()) do
    federations
    |> List.wrap()
    |> Enum.flat_map(fn f -> Map.get(f, :countries, []) end)
    |> Enum.uniq()
    |> Enum.sort()
    |> Enum.map(fn code -> Countries.get(code) end)
  end

  @doc """
  Lists all regions in the provided list of federations (or the default set if no federations are passed)

  ## Examples

      iex> SmeeFeds.regions()
      iex> SmeeFeds.federations([:ukamf, :incommon]) |> SmeeFeds.regions()
      ["Americas", "Europe"]
  """
  @spec regions(list(Federation.t())) :: list(struct())
  def regions(federations \\ federations()) do
    federations
    |> countries()
    |> Enum.map(fn c -> c.region end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Lists all sub_regions in the provided list of federations (or the default set if no federations are passed)

  ## Examples

      iex> SmeeFeds.sub_regions()
      iex> SmeeFeds.federations([:ukamf, :incommon]) |> SmeeFeds.sub_regions()
      ["Northern America", "Northern Europe"]
  """
  @spec sub_regions(list(Federation.t())) :: list(struct())
  def sub_regions(federations \\ federations()) do
    federations
    |> countries()
    |> Enum.map(fn c -> c.subregion end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Lists all super_regions in the provided list of federations (or the default set if no federations are passed)

  ## Examples

      iex> SmeeFeds.super_regions()
      iex> SmeeFeds.federations([:ukamf, :incommon]) |> SmeeFeds.super_regions()
      ["AMER", "EMEA"]
  """
  @spec super_regions(list(Federation.t())) :: list(struct())
  def super_regions(federations \\ federations()) do
    federations
    |> countries()
    |> Enum.map(fn c -> c.world_region end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  #############################################################################

end
