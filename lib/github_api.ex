defmodule GithubAPI do
  @token System.get_env("GH_TOKEN")

  def get(repo, endpoint, options \\ []) do
    get_url(repo, endpoint, options)
    |> fetch()
    |> process_results()
  end

  defp get_url(repo, endpoint, options) do
    "https://api.github.com/repos/newrelic"
    |> append(repo)
    |> append(endpoint)
    |> append(options)
  end

  defp fetch(url) do
    url
    |> call_github(authorization: "token #{@token}")
    |> decode_response()
  end

  defp process_results({:ok, results}) do
    results
    |> Enum.map(fn %{title: title} -> title end)
  end

  defp append(base, options) when is_list(options) do
    options
    |> Enum.map(fn {key, value} -> "#{key}=#{value}" end)
    |> Enum.join("&")
    |> case do
      "" -> base
      options_string -> "#{base}?#{options_string}"
    end
  end

  defp append(base, str), do: "#{base}/#{str}"

  defp call_github(url, headers) do
    url
    |> HTTPoison.get(headers)
    |> case do
      {:ok, %{body: body, status_code: code}} -> {code, body}
      {:error, %{reason: reason}} -> {:error, reason}
    end
  end

  defp decode_response({_code, body}) do
    body
    |> Poison.decode(keys: :atoms)
  end
end
