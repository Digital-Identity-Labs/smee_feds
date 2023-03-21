defmodule SmeeFeds.DataLoader do
  @moduledoc false

  @default_data_file Path.join(Application.app_dir(:smee_feds, "priv"), "data/federations.json")
  @external_resource @default_data_file
  @schema_file Path.join(Application.app_dir(:smee_feds, "priv"), "data/federations.json")
  @external_resource  @schema_file
  @schema File.read!(@schema_file)
          |> Jason.decode!()

  def load() do
    file()
    |> File.read!()
    |> Jason.decode!(keys: :atoms)
    |> validate()
    |> Enum.into(%{})
  end

  def file() do
    Application.get_env(:smee_feds, :data_file, @default_data_file)
  end

  def validate(json) do
    case ExJsonSchema.Validator.validate(@schema, json) do
      :ok -> json
      message -> raise "Unable to validate data at #{file()} using schema at #{@schema_file}: #{message}"
    end
  end

  #############################################################################


end
