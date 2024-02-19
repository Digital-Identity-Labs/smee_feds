defmodule SmeeFeds.Federation do
  @moduledoc """
  Federation provides structs that represents federated metadata publishers, and some simple tools to manage the
  information in them.
  """
  alias SmeeFeds.Federation
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
                   sources: [
                     type: {:map, :atom, :map},
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
  * `sources`: Map of atom IDs and `Smee.Source` structs. Use `default:` for the default aggregate, and `mdq:` for the
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

    federation = %Federation{
      id: String.to_atom("#{id}"),
      alt_ids: options[:alt_ids] || %{},
      type: String.to_atom("#{options[:type]}"),
      structure: String.to_atom("#{options[:structure]}"),
      descriptions: options[:descriptions] || %{},
      displaynames: options[:displaynames] || %{},
      logo: options[:logo],
      interfederates: options[:interfederates] || [],
      tags: options[:tags] || [],
      protocols: options[:protocols] || [:saml2],
      contact: options[:contact],
      name: options[:name],
      url: options[:url],
      uri: options[:uri],
      countries: normalize_country_codes(options[:countries]),
      policy: options[:policy],
      sources: %{}
    }

    sources = (options[:sources] || %{})
              |> Enum.map(
                   fn {id, data} -> {id, Smee.Source.new(data[:url], normalize_source_options(federation, id, data))}
                   end
                 )
              |> Enum.into(%{})

    struct(federation, %{sources: sources})

  end

  @doc """
  Gets the general contact information for the federation as a URL.
  """
  @spec contact(federation :: Federation.t()) :: binary()
  def contact(federation) do
    federation.contact
  end

  @doc """
  Lists all sources for the federation (it does not return their keys/labels)

  If no sources have been defined it will return an empty list.
  """
  @spec sources(federation :: Federation.t()) :: list(Source.t())
  def sources(federation) do
    Map.get(federation, :sources, %{})
    |> Map.values()
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

  #############################################################################

  @spec normalize_source_options(federation :: Federation.t(), id :: atom(), data :: map()) :: keyword()
  defp normalize_source_options(federation, id, data) do
    [
      id: id,
      type: normalize_source_type(data[:type]),
      cert_url: data[:cert_url],
      cert_fingerprint: data[:cert_fp],
      label: "#{federation.name}: #{id} #{normalize_source_type(data[:type])}"
    ]
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

end
