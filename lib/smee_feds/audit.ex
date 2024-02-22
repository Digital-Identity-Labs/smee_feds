defmodule SmeeFeds.Audit do
  @moduledoc false

  @doc """
  Connects to a remote web resource and uses HEAD HTTP method, with no caching, to check that the document is available

  Returns true if present, false if any error or unexpected status is returned
  """
  @spec resource_present?(url :: binary()) :: boolean()
  def resource_present?(url, _options \\ []) do
    try do
      if Smee.Utils.file_url?(url) do
        false
      else
        case Req.head(url, http_options()) do
          {
            :ok,
            %{
              status: 200
            }
          } -> true
          {:ok, %{status: _}} ->
            false
          {:error, _} ->
            false
        end
      end
    rescue
      _ -> false
    end
  end

  #############################

  @spec http_options(extra_options :: keyword()) :: keyword()
  defp http_options(extra_options \\ []) do
    Keyword.merge(
      [
        max_redirects: 3,
        cache: false,
        user_agent: "SmeeFeds #{Application.spec(:smee_feds, :vsn)}",
        # http_errors: :raise,
        max_retries: 0,
        retry_delay: &retry_jitter/1
      ],
      extra_options
    )
  end

  @spec retry_jitter(n :: integer()) :: integer()
  defp retry_jitter(n) do
    trunc(Integer.pow(2, n) * 1000 * (1 - 0.1 * :rand.uniform()))
  end

end
