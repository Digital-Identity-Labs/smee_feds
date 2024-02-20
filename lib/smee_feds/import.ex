defmodule SmeeFeds.Import do

  @schema_file Path.join(Application.app_dir(:smee_feds, "priv"), "data/federations.json")
  @external_resource @schema_file
  @schema File.read!(@schema_file)
          |> Jason.decode!()

  @mkeys [:active, :comment]

  alias SmeeFeds.Federation

  @spec json!(filename :: binary, options :: keyword()) :: map()
  def json!(filename, options \\ []) do
    filename
    |> File.read!()
    |> Jason.decode!(keys: :atoms)
      #   |> validate(filename)
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

#  def list(federations) do
#
#  end

  @spec validate(json :: map(), filename :: binary) :: map()
  def validate(json, filename) do
    case ExJsonSchema.Validator.validate(@schema, json) do
      :ok -> json
      message -> raise "Unable to validate data at #{filename} using schema at #{@schema_file}: #{message}"
    end
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
