defmodule SmeeFeds.Federation do
  @moduledoc """
  Federation provides structs that represents federated metadata publishers, and some simple tools to manage the
  information in them.
  """
  alias SmeeFeds.Federation
  alias SmeeFeds.Utils
  alias Smee.Source

  @enforce_keys [:id]

  @type t :: %__MODULE__{
               id: atom(),
               contact: nil | binary(),
               name: nil | binary(),
               alt_ids: map(),
               descriptions: map(),
               displaynames: map(),
               url: nil | binary(),
               uri: nil | binary(),
               policy: nil | binary(),
               logo: nil | binary(),
               countries: list(),
               protocols: list(),
               sources: map(),
               type: nil | atom(),
               structure: nil | atom(),
               interfederates: list(),
               tags: list(),
               autotag: boolean()
             }

  @derive Jason.Encoder
  defstruct [
    :id,
    :contact,
    :name,
    :url,
    :uri,
    countries: [],
    protocols: [],
    alt_ids: %{},
    descriptions: %{},
    displaynames: %{},
    policy: nil,
    logo: nil,
    sources: %{},
    interfederates: [],
    tags: [],
    structure: :mesh,
    type: :local,
    autotag: false
  ]

  @option_defs NimbleOptions.new!(
                 [
                   type: [
                     type: {:or, [:string, :atom]},
                     default: :local
                   ],
                   structure: [
                     type: {:or, [:string, :atom]},
                     default: :mesh
                   ],
                   alt_ids: [
                     type: {:map, :atom, :string},
                     default: %{}
                   ],
                   descriptions: [
                     type: {:map, :atom, :string},
                     default: %{}
                   ],
                   displaynames: [
                     type: {:map, :atom, :string},
                     default: %{}
                   ],
                   logo: [
                     type: {:or, [:string, :nil]},
                     default: nil
                   ],
                   autotag: [
                     type: :boolean,
                     default: false
                   ],
                   interfederates: [
                     type: {:list, {:or, [:string, :atom]}},
                     default: []
                   ],
                   tags: [
                     type: {:list, {:or, [:string, :atom]}},
                     default: []
                   ],
                   contact: [
                     type: :string,
                   ],
                   name: [
                     type: :string,
                   ],
                   url: [
                     type: :string,
                   ],
                   uri: [
                     type: :string,
                   ],
                   countries: [
                     type: {:list, {:or, [:string, :atom]}},
                   ],
                   protocols: [
                     type: {:list, {:or, [:string, :atom]}},
                   ],
                   policy: [
                     type: :string,
                   ],
                   id: [
                     type: {:or, [:string, :atom]}
                   ],
                   sources: [
                     type: {:or, [{:map, :atom, :map}, {:map, :atom, :keyword_list}, {:list, :any}]},
                     default: %{}
                   ]
                 ]
               )

  @doc """
  Creates a new Federation struct. The only requirement is a unique ID, passed as the first parameter.

  The ID should be a single unique word, as an atom.

  Other information can be passed as an option:

  default MDQ service.
  * `autotag`: Boolean, indicates that various explicit tags and inferred tags will be added to sources. Defaults to false.
  * `contact`: general contact address for the federation, as a URL.
  * `countries`: A list of 2-letter country codes for countries the federation officially provides services for.
  * `descriptions`: Map of language codes to descriptions for the federation
  * `displaynames`: Map of language codes to displaynames for the federation
  * `interfederates`: List of IDs of other federations this federation pushes data to
  * `protocols`: List of protocols supported by the federation - defaults to :saml2
  * `logo`: URL to the logo for the federation
  * `name`: The full, official, international name of the federation
  * `policy`: URL for the federation's metadata policy documentation
  * `alt_ids`: A map of alternative IDs, as used by other services, organisations and lists
  * `sources`: Map of atom IDs and `Smee.Source` structs or maps. Use `default:` for the default aggregate, and `mdq:` for the
    main MDQ service.
  * `structure`: Technical structure of the federation. Values are :mesh, :has, :hybrid. :Defaults to :mesh.
  * `tags`: List of tags which can be passed down to Sources, Metadata and Entities.
  * `type`: The *federation's* type. Possible values are :nren, :research, :inter, :misc, :mil, :com, :local. Defaults to :local
  * `uri`: The publisher URI of the federation
  * `url`: The URL of the federation's homepage

  Supported options: #{NimbleOptions.docs(@option_defs)}

  SmeeFeds comes with a list of built-in federations - use `SmeeFeds.federations/0` to view them.

  """
  @spec new(id :: atom() | binary(), options :: keyword()) :: Federation.t()
  def new(id, options \\ []) do

    options = options
              |> Enum.reject(fn {_k, v} -> is_nil(v) end)
              |> NimbleOptions.validate!(@option_defs)

    %Federation{
      id: String.to_atom("#{id}"),
      alt_ids: options[:alt_ids] || %{},
      type: String.to_atom("#{options[:type]}"),
      structure: String.to_atom("#{options[:structure]}"),
      descriptions: options[:descriptions] || %{},
      displaynames: options[:displaynames] || %{},
      logo: options[:logo],
      interfederates: Utils.to_safe_atoms(options[:interfederates] || []),
      tags: options[:tags] || [],
      protocols: Utils.to_safe_atoms(options[:protocols] || [:saml2]),
      contact: normalize_contact(options[:contact]),
      name: options[:name],
      url: options[:url],
      uri: options[:uri],
      countries: normalize_country_codes(options[:countries]),
      policy: options[:policy],
      sources: process_sources(options[:sources], id),
      autotag: options[:autotag]
    }
    |> init_autotagger()

  end

  @doc """
  Gets the general contact information for the federation as a URL.
  """
  @spec contact(federation :: Federation.t()) :: binary()
  def contact(federation) do
    federation.contact
  end

  @doc """
  Returns the default MDQ service for the federation, or nil if none has been defined.

  """
  @spec mdq(federation :: Federation.t()) :: Source.t() | nil
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
    Enum.find(sources, fn {_id, source} -> source.type == :mdq end)
    |> case() do
         {_id, source} -> source
         nil -> nil
       end
  end

  @doc """
  Returns the default aggregate metadata details for the federation, or nil if none has been defined.

  """
  @spec aggregate(federation :: Federation.t()) :: Source.t() | nil
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
    Enum.find(sources, fn {_id, source} -> source.type == :aggregate end)
    |> case() do
         {_id, source} -> source
         nil -> nil
       end
  end

  @doc """
  Returns the homepage URL for the federation, or nil.

  """
  @spec url(federation :: Federation.t()) :: binary()
  def url(federation) do
    federation.url
  end

  @doc """
  Returns the policy URL for the federation (if known) or nil

  """
  @spec policy_url(federation :: Federation.t()) :: binary()
  def policy_url(federation) do
    federation.policy
  end

  @doc """
  Returns the countries associated with the federation as `Countries` structs.

  See [Countries](https://hexdocs.pm/countries/api-reference.html) documentation for more information.
  """
  @spec countries(federation :: Federation.t()) :: list(binary())
  def countries(%Federation{countries: trouble}) when is_nil(trouble) or trouble == []  do
    []
  end

  def countries(federation) do
    Map.get(federation, :countries, [])
    |> Enum.map(fn code -> Countries.get(code) end)
    |> ugh_brexit!()
  end

  @doc """
  Returns an ID for the federation, of the specified type. Defaults to the main (`:smee`) ID

  * `:smee` - returns the main ID
  * `:uri` - returns the publishing/registration URI
  * `:uri_hash` - returns sha1 hash of the federation's URI

  If other keys are available in the data they can also be specified. The example data has `:edugain` and `:met` IDs.

  """
  @spec id(federation :: Federation.t(), id_type :: atom()) :: atom() | binary()
  def id(federation, id_type \\ :smee) do
    case id_type do
      :smee ->
        Map.get(federation, :id)
      :uri ->
        Map.get(federation, :uri)
      :uri_hash ->
        Smee.Utils.sha1(Map.get(federation, :uri, nil))
      other_id ->
        Map.get(federation, :alt_ids, %{})
        |> Map.get(other_id, nil)
    end
  end

  @doc """
  Returns the sources of the federation struct, as a list of Source structs

  If no sources have been defined it will return an empty list.
  """
  @spec sources(federation :: Federation.t()) :: list(Source.t())
  def sources(federation) do
    Map.get(federation, :sources, %{})
    |> Map.values()
  end

  @doc """
  Returns the federation with the specified Smee Source structs set as the list of sources, replacing previous sources.

  Only proper Source structs will be added, everything else will be silently ignored.

  Sources with IDs will be added with those IDs. Sources without IDs will be added with IDs like "source0", "source1", etc.
    Sources with conflicting IDs will be overwritten by the last one in the list.
  """
  @spec sources(federation :: Federation.t(), sources :: Smee.Source.t() | list(Smee.Source.t())) :: Federation.t()
  def sources(federation, sources) do

    %{
      federation |
      sources: process_sources(sources, federation.id)
    }

  end

  @doc """
  Returns the tags of the federation struct, a list of binary strings

  Tags are arbitrary strings.
  """
  @spec tags(federation :: Federation.t()) :: list(binary())
  def tags(federation) do
    federation.tags || []
  end

  @doc """
  Tags a federation record with one or more tags, replacing existing tags.

  Tags are arbitrary strings.
  """
  @spec tag(federation :: Federation.t(), tags :: list() | nil | binary()) :: Federation.t()
  def tag(federation, tags) do
    struct(federation, %{tags: Smee.Utils.tidy_tags(tags)})
  end

  @doc """
  Tags a federation record with one or more tags generated automatically from the federation's other
    details, returning an updated Federation struct.

  Tags will include the federation ID, type, structure, countries, source type, and so on.

  Sources in the Federation will also be tagged, and these tags will be inherited by Metadata and Entity structs
    derived from the Source.
  """
  @spec autotag!(federation :: Federation.t(), _options :: keyword()) :: Federation.t()
  def autotag!(federation, _options \\ []) do
    original_tags = tags(federation)
    attr_tags = [federation.structure, federation.type, federation.id]
    c_tags = federation.countries
    f_tags = (original_tags ++ attr_tags ++ c_tags)
             |> Smee.Utils.tidy_tags()
             |> Enum.uniq() # TODO: Bug in Smee?

    sources = federation.sources
              |> Enum.map(
                   fn {k, s} ->
                     s_tags = (s.tags ++ [s.type] ++ f_tags)
                              |> Smee.Utils.tidy_tags()
                              |> Enum.uniq() # TODO: Bug in Smee?
                     {k, %{s | tags: s_tags}}
                   end
                 )
              |> Enum.into(%{})

    %{federation | tags: f_tags, sources: sources}
  end

  @doc """
  Returns a displayname for the federation struct, attempting to use the specified language, but returning
    the English displayname or name for the Federation if that isn't available.
  """
  @spec displayname(federation :: Federation.t(), lang :: atom()) :: binary()
  def displayname(federation, lang \\ :en) do
    texts = Map.get(federation, :displaynames, %{})
    Map.get(texts, lang, nil) || Map.get(texts, :en, nil) || federation.name
  end

  @doc """
  Returns a description for the federation struct, attempting to use the specified language, but returning
    the English description if that isn't available. Nil will be returned if no suitable language can be found.
  """
  @spec description(federation :: Federation.t(), lang :: atom()) :: binary()
  def description(federation, lang \\ :en) do
    texts = Map.get(federation, :descriptions, %{})
    Map.get(texts, lang, nil) || Map.get(texts, :en, nil)
  end

  @doc """
  Returns a source with the specified source ID, or URL, or nil if one cannot be found.

  IDs will be unique but URLs might not be, so the first matching source will be returned.
  """
  @spec source(federation :: Federation.t(), id :: atom() | binary()) :: Smee.Source.t() | nil
  def source(federation, id) when is_atom(id) do
    federation.sources[id]
  end

  def source(federation, id) when is_binary(id) do
    sources(federation)
    |> Enum.find(fn f -> f.url == id end)
  end

  #############################################################################

  @spec normalize_source_options(id :: atom(), fedid :: atom(), data :: map()) :: keyword()
  defp normalize_source_options(id, fedid, data) do
    type = normalize_source_type(data[:type])
    Keyword.merge(
      Keyword.new(data),
      [
        id: id,
        type: type,
        label: "#{id} #{type}",
        fedid: Utils.to_safe_atom(fedid)
      ]
    )
  end

  @spec normalize_source_type(type :: nil | atom() | binary()) :: atom()
  defp normalize_source_type(type) do
    cond  do
      is_nil(type) -> :aggregate
      type == "" -> :aggregate
      is_atom(type) -> type
      is_binary(type) -> String.to_existing_atom(type)
    end
  end

  @spec normalize_country_codes(countries_list :: list(atom() | binary())) :: list(binary())
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

  @spec ugh_brexit!(countries :: list()) :: list()
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

  @spec process_sources(sources :: list() | map() | Smee.Source.t(), fedid :: atom()) :: map()
  defp process_sources(nil, _) do
    %{}
  end

  defp process_sources(sources, fedid) when is_map(sources) do
    sources
    |> Enum.map(
         fn {id, data} -> {id, Smee.Source.new(data[:url], normalize_source_options(id, fedid, data))}
         end
       )
    |> Enum.into(%{})
  end

  defp process_sources(sources, fedid) when is_list(sources) do
    sources
    |> List.wrap()
    |> Enum.filter(fn x -> is_struct(x, Smee.Source) end)
    |> Enum.with_index()
    |> Enum.map(fn {source, i} -> {(source.id || :"source#{i}"), source} end)
    |> Enum.map(fn {id, source} -> {id, %{source | id: id, fedid: fedid}} end)
    |> Enum.into(%{})
  end

  @spec normalize_contact(contact :: binary() | nil) :: binary()
  defp normalize_contact(nil) do
    nil
  end

  defp normalize_contact(contact) do
    String.replace_leading(contact, "mailto:", "")
  end

  @spec init_autotagger(federation :: Federation.t(), options :: keyword()) :: Federation.t()
  defp init_autotagger(federation, options \\ [])
  defp init_autotagger(%{autotag: true} = federation, options) do
    autotag!(federation, options)
  end

  defp init_autotagger(federation, _options) do
    federation
  end

end
