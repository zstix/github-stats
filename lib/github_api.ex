defmodule GithubAPI do
  @token System.get_env("GH_TOKEN")

  # defp get_points(labels) do
  # labels
  # |> Enum.map(fn %{name: name} -> name end)
  # |> Enum.find(&String.match?(&1, ~r/sp\:[0-9]/))
  # |> case do
  # nil ->
  # 0

  # name ->
  # name
  # |> String.split(":")
  # |> Enum.reverse()
  # |> hd()
  # |> String.to_integer()
  # end
  # end

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
            issues(first: 3) {
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
    %{
      title: title,
      points: get_issues(issues)
    }
  end

  # desired output [{title: "stuff", points: 0,} {}]
  defp get_issues(issues) do
    issues
    |> Map.fetch!("nodes")
    |> Enum.map(fn %{"labels" => %{"nodes" => nodes}} -> nodes end)
    |> IO.inspect()

    # |> Enum.map(get_issue)
  end

  defp get_issue(issue) do
    IO.inspect(issue)
  end
end
