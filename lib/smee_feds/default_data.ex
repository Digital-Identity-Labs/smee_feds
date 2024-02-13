defmodule SmeeFeds.DefaultData do
  @moduledoc false

  alias SmeeFeds.Import

  @default_data_file Path.join(Application.app_dir(:smee_feds, "priv"), "data/federations.json")
  @external_resource @default_data_file
  @federations Import.json!(@default_data_file, active: true)

  @spec federations() :: map()
  def federations do
    if (production_environment?() && using_bundled_data?()) do
      IO.warn "Please do not use the default SmeeFeds database in production"
    end
    @federations
  end

  @spec file() :: binary()
  def file() do
    Application.get_env(:smee_feds, :data_file, @default_data_file)
  end

  def using_bundled_data? do
    file() == @default_data_file
  end

  @spec production_environment?() :: boolean()
  def production_environment? do

    cond do
      function_exported?(Mix, :env, 0) && apply(Mix, :env, []) == :prod -> true
      System.get_env("MIX_ENV") == "prod" -> true
      function_exported?(Mix, :env, 0) && apply(Mix, :env, []) == :test -> false
      function_exported?(Mix, :env, 0) && apply(Mix, :env, []) == :dev -> false
      System.get_env("MIX_ENV") == "test" -> false
      System.get_env("MIX_ENV") == "dev" -> false
      true -> true
    end

  end


end
