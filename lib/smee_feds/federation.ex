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
               url: nil | binary(),
               uri: nil | binary(),
               policy: nil | binary(),
               countries: list(),
               sources: map()
             }

  defstruct [
    :id,
    :contact,
    :name,
    :url,
    :uri,
    countries: [],
    policy: nil,
    sources: %{}
  ]

  @doc """
  Creates a new Federation struct. The only requirement is a unique ID, passed as the first parameter.

  Other information can be passed as an option:

  * `contact`: general contact address for the federation, as a URL.
  * `name`: The full, official name of the federation
  * `url`: The URL of the federation's homepage
  * `uri`: The publisher URI of the federation
  * `countries`: A list of 2-letter country codes for countries the federation officially provides services for.
  * `policy`: URL for the federation's metadata policy documentation
  * `sources`: Map of atom IDs and `Smee.Source` structs. Use `default:` for the default aggregate, and `mdq:` for the
    default MDQ service.

  SmeeFeds comes with a list of built-in federations - use `SmeeFeds.federations/0` to view them.

  """
  @spec new(id :: atom() | binary(), options :: keyword() ) :: Federation.t()
  def new(id, options \\ []) do

    federation = %Federation{
      id: String.to_atom("#{id}"),
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
                   fn {id, data} -> {id, Smee.Source.new(data[:url], normalize_source_options(federation, data))} end
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

  #############################################################################

  @spec normalize_source_options(federation ::  Federation.t(), data :: map() ) :: keyword()
  defp normalize_source_options(federation, data) do
    [
      type: normalize_source_type(data[:type]),
      cert_url: data[:cert_url],
      cert_fingerprint: data[:cert_fp],
      label: "#{federation.name}: #{data[:type]}"
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
