defmodule GithubAPI do
  @token System.get_env("GH_TOKEN")

  defp process_results({:ok, results}) do
    results
    |> Enum.map(fn %{id: id, title: title, labels: labels} ->
      %{id: id, title: title, points: get_points(labels)}
    end)
  end

  defp get_points(labels) do
    labels
    |> Enum.map(fn %{name: name} -> name end)
    |> Enum.find(&String.match?(&1, ~r/sp\:[0-9]/))
    |> case do
      nil ->
        0

      name ->
        name
        |> String.split(":")
        |> Enum.reverse()
        |> hd()
        |> String.to_integer()
    end
  end

  def call_github(query, variables) do
    url = "https://api.github.com/graphql"
    headers = [Authorization: "bearer #{@token}"]
    variables = Map.put(variables, "owner", "newrelic")

    query
    |> Neuron.query(variables, url: url, headers: headers)
    |> case do
      {:ok, %{body: body, status_code: 200}} -> body
      {:error, %{reason: reason}} -> {:error, reason}
    end
  end
end
