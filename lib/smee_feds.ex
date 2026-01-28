defmodule SmeeFeds do
  @moduledoc """
  `SmeeFeds` is a SAML federation data management extension to [Smee](https://github.com/Digital-Identity-Labs/smee) for use in
  research, testing and development.

  [Smee](https://github.com/Digital-Identity-Labs/smee) has tools for handling the sources of SAML metadata but
  nothing to represent the publishers of metadata. SmeeFeds adds a few tools for handling federations and includes a large
  collection of information about research and education federations.

  ## Features

  * Easily find information on National Research and Education organisation (NREN) federations.
  * Filter and group federations by location, type, structure and tags.
  * Use federation records directly with Smee to download metadata from aggregates or MDQ servers
  * Export lists of federation information as CSV, JSON or Markdown documents
  * Manage and load federation data into your applications

  The top level `SmeeFeds` module has tools for selecting individual federation details or lists of many at once.
  SmeeFeds contain more tools for handling federations, such as:

  * `SmeeFeds.Federation` - tools for accessing data such as metadata download URLs, contacts, homepages, and so on.
  * `SmeeFeds.Export` - convert lists of federations into JSON or CSV data for export, or simple text reports
  * `SmeeFeds.Import` - convert JSON documents into Federation lists
  * `SmeeFeds.Filter` - filter lists of federations by various criteria

  ## IMPORTANT DISCLAIMER AND WARNING

  SmeeFeds comes with a built-in list of federations, using information gathered from various sources on the Internet.

  This collection of information is example data for use by **researchers, developers and testers**.

  **IT IS NOT FOR USE IN PRODUCTION ENVIRONMENTS**

  Metadata is the bedrock of trust and information security in SAML federations. DO NOT use metadata URLs, certificates
  and certificate fingerprints to download and use metadata in live services without confirming each detail yourself.

  If you must use SmeeFeds as part of a production service, then after information has been verified you can export only
  the verified information you need as a JSON file and set it as the new default using
  `:smee_feds, :data_file` config setting in your application (if compiled) or set a list of Federations with
  `:smee_feds, :federations` at runtime.

  There is absolutely no guarantee or warranty that the data in SmeeFeds is correct, and it is not supported by any of
  the federations listed. It's totally unofficial.
  """

  alias SmeeFeds.Federation
  alias SmeeFeds.DefaultData
  alias SmeeFeds.Utils
  alias Smee.Metadata
  alias Smee.Entity
  alias Smee.Source

  @doc """
  Returns a list of `SmeeFeds.Federation` structs from the default collection.

  Returns all known federations from the default collection.

  ## Example
      iex> federations = SmeeFeds.federations()
      iex> Enum.count(federations)
      77
  """
  @spec federations() :: list(Federation.t())
  def federations() do
    DefaultData.federations()
    |> Map.values()
    |> Enum.sort_by(& &1.id)
  end

  @doc """
  Returns a list of the specified `SmeeFeds.Federation` structs from the default collection.

  ## Example
      iex> federations = SmeeFeds.federations([:ukamf, :wayf])
      iex> Enum.count(federations)
      2
  """
  @spec federations(ids :: atom() | list(atom() | binary())) :: list(Federation.t())
  def federations(ids) do
    DefaultData.federations()
    |> Map.take(Utils.to_safe_atoms(ids))
    |> Map.values()
  end

  @doc """
  Finds a federation in the default database by ID and returns the full federation record.

  ## Example
      iex> incommon = SmeeFeds.federation(:incommon)
      iex> incommon.policy
      "https://incommon.org/about/policies/"
  """
  @spec federation(federation :: atom() | binary()) :: Federation.t() | nil
  def federation(id) do
    DefaultData.federations()
    |> Map.get(Utils.to_safe_atom(id))
  end

  @doc """
  Returns the ids of all federations in the provided list of federations as a list of atoms.

  ## Example
       iex> ids = SmeeFeds.ids(SmeeFeds.federations())
       iex> Enum.slice(ids, 0..3)
       [:aaf, :aaieduhr, :aaiedumk, :aconet]
  """
  @spec ids(federations :: list()) :: list(atom())
  def ids(federations) do
    federations
    |> Enum.map(fn f -> f.id end)
  end

  @doc """
  Returns a filtered list of `SmeeFeds.Federation` structs when passed a list of
   federations and federation IDs (as atoms) to select.

  ## Example

      iex> all_federations = SmeeFeds.federations()
      iex> my_federations = SmeeFeds.take(all_federations, [:ukamf, :switch])
      iex> Enum.map(my_federations, fn f -> f.name end)
      ["SWITCHaai", "UK Access Management Federation"]
  """
  @spec take(federations :: list(), federation_ids :: list(atom())) :: list(Federation.t())
  def take(federations, federation_ids) when is_list(federations) do
    federations
    |> SmeeFeds.Filter.ids(federation_ids)
  end

  @doc """
  Finds a federation in the supplied list by ID and returns the full federation record.

  ## Example
      iex> federations = SmeeFeds.federations()
      iex> incommon = SmeeFeds.get(federations, :incommon)
      iex> incommon.url
      "http://incommon.org/"
  """
  @spec get(federations :: list(), id :: atom() | binary()) :: Federation.t() | nil
  def get(federations, id) do
    federations
    |> Enum.find(fn f -> Utils.to_safe_atom(id) == f.id end)
  end

  @doc """
  Tries to find the federation that published the provided Smee record (source, entity or metadata)

  The first matching federation record will be returned if found, or nil if no federations match.

  ## Example

      iex> source = Smee.source("http://metadata.ukfederation.org.uk/ukfederation-metadata.xml")
      iex> federations = SmeeFeds.federations()
      iex> federation = SmeeFeds.publisher(federations, source)
      %SmeeFeds.Federation{id: :ukamf} = federation

  """
  @spec publisher(federations :: list(), smee_struct :: Source.t() | Metadata.t() | Entity.t()) :: Federation.t() | nil
  def publisher(federations, smee_struct) do
    federations
    |> Enum.find(fn federation -> publisher?(federation, smee_struct)  end)
  end

  @doc """
  Is a federation the publisher of the provided Smee Source, Metadata, or Entity?

  Returns true if the federation and source, metadata or entity share a URL or publisher URI, false otherwise.

  ## Example

      iex> source = Smee.source("http://metadata.ukfederation.org.uk/ukfederation-metadata.xml")
      iex> federations = SmeeFeds.federations()
      iex> federation = SmeeFeds.get(federations, :ukamf)
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

  ## Needs an update to Smee S, M, E modules first
  #  def registrar()
  #  def registrar?()

  @doc """
  Lists all countries in the provided list of federations

  ## Examples

      iex> SmeeFeds.federations([:ukamf, :incommon]) |> SmeeFeds.countries()

  """
  @spec countries(federations :: list(Federation.t())) :: list(struct())
  def countries(federations) do
    federations
    |> List.wrap()
    |> Enum.flat_map(fn f -> Map.get(f, :countries, []) end)
    |> Enum.uniq()
    |> Enum.sort()
    |> Enum.map(fn code -> Countries.get(code) end)
  end

  @doc """
  Lists all regions in the provided list of federations

  ## Examples

      iex> SmeeFeds.federations([:ukamf, :incommon]) |> SmeeFeds.regions()
      ["Americas", "Europe"]
  """
  @spec regions(federations :: list(Federation.t())) :: list(struct())
  def regions(federations) do
    federations
    |> countries()
    |> Enum.map(fn c -> c.region end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Lists all sub_regions in the provided list of federations

  ## Examples

      iex> SmeeFeds.federations([:ukamf, :incommon]) |> SmeeFeds.sub_regions()
      ["Northern America", "Northern Europe"]
  """
  @spec sub_regions(federations :: list(Federation.t())) :: list(struct())
  def sub_regions(federations) do
    federations
    |> countries()
    |> Enum.map(fn c -> c.subregion end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Lists all super_regions in the provided list of federations

  ## Examples

      iex> SmeeFeds.federations([:ukamf, :incommon]) |> SmeeFeds.super_regions()
      ["AMER", "EMEA"]
  """
  @spec super_regions(federations :: list(Federation.t())) :: list(struct())
  def super_regions(federations) do
    federations
    |> countries()
    |> Enum.map(fn c -> c.world_region end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Lists all federation types in the provided list of federations, as atoms.

  ## Examples

      iex> SmeeFeds.federations() |> SmeeFeds.types()
      [:inter, :misc, :nren, :research]
  """
  @spec types(federations :: list(Federation.t())) :: list(atom())
  def types(federations) do
    federations
    |> Enum.map(fn f -> Map.get(f, :type) end)
    |> Enum.uniq
    |> Enum.sort()
  end

  @doc """
  Lists all types of structures in the provided list of federations, as atoms.

  ## Examples

      iex> SmeeFeds.federations() |> SmeeFeds.structures()
      [:has, :mesh]
  """
  @spec structures(federations :: list(Federation.t())) :: list(atom())
  def structures(federations) do
    federations
    |> Enum.map(fn f -> Map.get(f, :structure) end)
    |> Enum.uniq
    |> Enum.sort()
  end

  @doc """
  Lists all ID types in the provided list of federations, as atoms.

  ## Examples

      iex> SmeeFeds.federations() |> SmeeFeds.id_types()
      [:edugain, :met, :smee, :uri]
  """
  @spec id_types(federations :: list(Federation.t())) :: list(atom())
  def id_types(federations) do
    federations
    |> Enum.map(
         fn f ->
           Map.get(f, :alt_ids, %{})
           |> Map.keys() end
       )
    |> Enum.concat([:smee, :uri])
    |> List.flatten()
    |> Enum.uniq
    |> Enum.sort()
  end

  @doc """
  Lists all unique tags in the provided list of federations, as atoms.

  ## Examples

      iex> SmeeFeds.federations() |> SmeeFeds.tags()
      ["noSlow", "noTest"]
  """
  @spec tags(federations :: list(Federation.t())) :: list(atom())
  def tags(federations) do
    federations
    |> Enum.map(fn f -> Map.get(f, :tags) end)
    |> List.flatten()
    |> Enum.uniq
    |> Enum.sort()
  end

  @doc """
  Lists all unique protocols in the provided list of federations, as atoms.

  ## Examples

      iex> SmeeFeds.federations() |> SmeeFeds.protocols()
      [:saml2]
  """
  @spec protocols(federations :: list(Federation.t())) :: list(atom())
  def protocols(federations) do
    federations
    |> Enum.map(fn f -> Map.get(f, :protocols) end)
    |> List.flatten()
    |> Enum.uniq
    |> Enum.sort()
  end

  @doc """
  Lists all upstream federation IDs in the provided list of federations, as atoms.

  ## Examples

      iex> SmeeFeds.federations() |> SmeeFeds.upstream()
      [:edugain]
      iex> [%SmeeFeds.Federation{id: :edugain}] =  SmeeFeds.federations |> SmeeFeds.upstream() |> SmeeFeds.federations()

  """
  @spec upstream(federations :: list(Federation.t())) :: list(atom())
  def upstream(federations) do
    federations
    |> Enum.map(fn f -> Map.get(f, :interfederates) end)
    |> List.flatten()
    |> Enum.uniq
    |> Enum.sort()
  end

  @doc """
  Returns a federation record if one with the specified ID is present in the list, or nil if one can't be found

  Available IDs can be found using `SmeeFeds.id_types/1`. Two are built-in: `:uri` and `:smee`. Any other
    ID key used in the `alt_ids` part of the Federation struct can be searched.

  ## Examples

      iex> SmeeFeds.federations() |> SmeeFeds.get_by(:uri, "http://ukfederation.org.uk")
      iex> SmeeFeds.federations() |> SmeeFeds.get_by(:edugain,  "HAKA")

  """
  @spec get_by(federations :: list(Federation.t()), id_type :: atom(), id :: atom() | binary()) :: Federation.t() | nil
  def get_by(federations, id_type, id)
  def get_by(federations, :smee, id) do
    get(federations, id)
  end

  def get_by(federations, :uri, id) do
    federations
    |> Enum.find(fn f -> id == f.uri end)
  end

  def get_by(federations, id_type, id) do

    id = "#{id}"
    id_type = Utils.to_safe_atom(id_type)

    federations
    |> Enum.find(
         fn f ->
           id == Map.get(f, :alt_ids, %{})
                 |> Map.get(id_type, nil) end
       )

  end

  @doc """
  Accepts a list of federations, and returns a list of federations with tags automatically added.

  Uses `Federation.autotag!/2`, and works with lists and streams.

  ## Examples

      iex> tags = SmeeFeds.federations() |> SmeeFeds.autotag!() |> SmeeFeds.tags()
      iex> "mesh" in tags
      true

  """
  @spec autotag!(enum :: Enumerable.t(),  options :: keyword()) :: Enumerable.t()
  def autotag!(federations, options \\ []) do
    federations
    |> List.wrap()
    |> Enum.map(fn f -> Federation.autotag!(f, options) end)
  end


  #############################################################################


end
