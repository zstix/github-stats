defmodule GithubAPI do
  @token System.get_env("GH_TOKEN")

  def get_url(repo, endpoint) do
    "https://api.github.com/repos/newrelic/#{repo}/#{endpoint}"
  end

  def fetch(url) do
    url
    |> call_github(authorization: "token #{@token}")
    |> decode_response()
  end

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
