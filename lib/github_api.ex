defmodule GithubAPI do
  @token System.get_env("GH_TOKEN")

  def query_github({:burndown, vars: vars}) do
    query = """
      query getIssues(
        $owner: String!,
        $repository: String!,
        $milestone: Int!
      ) {
        repository(name: $repository, owner: $owner) {
          milestone(number: $milestone) {
            title
            issues(first: 100) {
              nodes {
                title
                labels(first: 10) {
                  nodes {
                    name
                  }
                }
              }
            }
          }
        }
      }
    """

    query_github(query, vars)
  end

  def query_github(query, variables) do
    url = "https://api.github.com/graphql"
    headers = [Authorization: "bearer #{@token}"]
    variables = Map.put(variables, "owner", "newrelic")

    query
    |> Neuron.query(variables, url: url, headers: headers)
    |> case do
      {:ok, %{body: body, status_code: 200}} -> body
      {:error, %{reason: reason}} -> {:error, reason}
    end
    |> process_response()
  end

  defp process_response(%{
         "data" => %{
           "repository" => %{
             "milestone" => %{
               "issues" => issues,
               "title" => title
             }
           }
         }
       }) do
    %{title: title, issues: get_issues(issues)}
  end

  defp get_issues(%{"nodes" => nodes}) do
    nodes
    |> Enum.map(&get_issue/1)
  end

  defp get_issue(%{"title" => title, "labels" => labels}) do
    %{title: title, points: get_points(labels)}
  end

  defp get_points(%{"nodes" => nodes}) do
    nodes
    |> Enum.map(fn %{"name" => name} -> name end)
    |> Enum.find("sp:0", &String.match?(&1, ~r/sp\:[0-9]/))
    |> String.split(":")
    |> Enum.reverse()
    |> hd()
    |> String.to_integer()
  end
end
