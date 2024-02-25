defmodule SmeeFeds.Import do

  @moduledoc """
  Converts serialised federation data into the Federation structs used by SmeeFeds.

  Please see the `Export` module too.
  """

  @mkeys [:active, :comment, :todo]

  alias SmeeFeds.Federation

  @doc """
  Reads the specified filename and returns a list of Federations

  The JSON format is expected to be the same as that as `Export.json_file!` and  `Export.json!`
  """
  @spec json_file!(filename :: binary()) :: list()
  def json_file!(filename) do
    filename
    |> File.read!()
    |> json!()
  end

  @doc """
  Parses the JSON string and returns a list of Federations.

  The JSON format is expected to be the same as that as `Export.json_file!` and  `Export.json!`
  """
  @spec json!(data :: binary()) :: list()
  def json!(data) do
    data
    |> Jason.decode!(keys: :atoms)
    |> Enum.map(fn data -> Federation.new(data[:id], data) end)
  end

  @doc """
  Reads the specified filename and returns a map of Federations

  This format is intended for use inside `SmeeFeds` as the default federation data. In most cases it is better
    to use `Import.json_file!` instead.

  The JSON format is expected to be the same as that as `Export.dd_json_file!` and  `Export.dd_json!`
  """
  @spec dd_json_file!(filename :: binary, options :: keyword()) :: map()
  def dd_json_file!(filename, options \\ []) do
    filename
    |> File.read!()
    |> dd_json!(options)
  end

  @doc """
  Parses the JSON string and returns a map of Federations.

  This format is intended for use inside `SmeeFeds` as the default federation data. In most cases it is better
    to use `Import.json!` instead.

  The JSON format is expected to be the same as that as `Export.dd_json_file!` and  `Export.dd_json!`
  """
  @spec dd_json!(data :: binary, options :: keyword()) :: map()
  def dd_json!(data, options \\ []) do
    data
    |> Jason.decode!(keys: :atoms)
    |> Enum.into(%{})
    |> filter_active(options)
    |> Enum.map(
         fn {id, data} ->
           data = Map.drop(data, @mkeys)
                  |> Keyword.new()
           {
             id,
             Federation.new(
               id,
               data
             )
           }
         end
       )
    |> Enum.sort()
    |> Enum.into(%{})
  end

  #############################################################################

  @spec filter_active(data :: map(), options :: keyword()) :: map()
  defp filter_active(data, options) do
    if Keyword.get(options, :active, false) do
      data
      |> Enum.reject(
           fn
             {_id, %{active: active}} -> active == false
             {_, _} -> false
           end
         )
    else
      data
    end

  end

end
