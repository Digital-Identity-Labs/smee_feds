defmodule SmeeFeds.DataLoader do

  @moduledoc false


  @default_data_file Path.join(Application.app_dir(:smee_feds, "priv"), "data/federation_metadata.json")
  @external_resource @default_data_file

  def load() do

    file()
    |> File.read!()
    |> Jason.decode!(keys: :atoms)
    |> Enum.into(%{})

  end

  def file() do
    Application.get_env(:smee_feds, :data_file, @default_data_file)
  end

end
