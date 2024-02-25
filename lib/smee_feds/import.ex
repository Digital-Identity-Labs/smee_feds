defmodule SmeeFeds.Import do

  @moduledoc """
  Converts serialised federation data into the Federation structs used by SmeeFeds.

  Please see the `Export` module too.
  """

  @mkeys [:active, :comment, :todo]

  alias SmeeFeds.Federation

  @doc """

  """
  @spec json_file!(filename :: binary()) :: list()
  def json_file!(filename) do
    filename
    |> File.read!()
    |> json!()
  end

  @doc """

  """
  @spec json_file!(data :: binary()) :: list()
  def json!(data) do
    data
    |> Jason.decode!(keys: :atoms)
    |> Enum.map(fn data -> Federation.new(data[:id], data) end)
  end

  @doc """

  """
  @spec dd_json_file!(filename :: binary, options :: keyword()) :: map()
  def dd_json_file!(filename, options \\ []) do
    filename
    |> File.read!()
    |> dd_json!(options)
  end

  @doc """

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

  def filter_active(data, options) do
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
