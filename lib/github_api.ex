defmodule GithubAPI do
  @token System.get_env("GH_TOKEN")

  def query_github({:burndown, vars: vars}, start_date, end_date) do
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
                timelineItems(first: 50) {
                  nodes {
                    ... on MovedColumnsInProjectEvent {
                      previousProjectColumnName
                      projectColumnName
                      createdAt
                    }
                  }
                }
              }
            }
          }
        }
      }
    """

    query_github(query, vars)
    |> process_response(:burndown, start_date, end_date)
  end

  def query_github(query, variables) do
    url = "https://api.github.com/graphql"

    headers = [
      Authorization: "bearer #{@token}",
      Accept: "application/vnd.github.starfox-preview+json"
    ]

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

  defp get_issue(%{
         "title" => title,
         "labels" => labels,
         "timelineItems" => timeline
       }) do
    %{title: title, points: get_points(labels), history: get_history(timeline)}
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

  defp get_history(%{"nodes" => nodes}) do
    nodes
    |> Enum.filter(fn item -> item !== %{} end)
    |> Enum.map(&format_event/1)
  end

  defp format_event(%{
         "createdAt" => date,
         "previousProjectColumnName" => from,
         "projectColumnName" => to
       }) do
    %{from: from, to: to, date: date}
  end

  defp process_response(milestone, :burndown, start_date, end_date) do
    %{
      title: milestone.title,
      data:
        Date.range(
          Date.from_iso8601!(start_date),
          Date.from_iso8601!(end_date)
        )
        |> Enum.filter(fn date -> Date.day_of_week(date) <= 5 end)
        |> Enum.map(&get_stats_for_date(&1, milestone.issues))
        |> Enum.map(fn %{date: date} = data ->
          case Date.compare(date, Date.utc_today()) do
            :gt -> %{data | date: date, todo: 0}
            _ -> data
          end
        end)
    }
  end

  defp get_stats_for_date(date, issues) do
    issues
    |> Enum.reduce(
      %{todo: 0, in_progress: 0, in_review: 0, done: 0},
      &get_stats_for_date(&1, date, &2)
    )
    |> Map.merge(%{date: date})
  end

  defp get_stats_for_date(%{history: [], points: points}, _date, stats) do
    %{stats | todo: stats.todo + points}
  end

  defp get_stats_for_date(%{history: history, points: points}, date, stats) do
    history
    |> Enum.map(fn %{date: date, to: to} -> %{date: get_date(date), to: to} end)
    |> Enum.filter(fn %{date: idate} -> Date.compare(idate, date) != :lt end)
    |> case do
      [] ->
        %{stats | todo: stats.todo + points}

      events ->
        events
        |> Enum.reduce(hd(events), fn
          %{date: idate} = event, _acc when idate == date -> event
          _event, acc -> acc
        end)
        |> Map.get(:to)
        |> case do
          "In progress" -> %{stats | in_progress: stats.in_progress + points}
          "In review" -> %{stats | in_review: stats.in_review + points}
          "Done" -> %{stats | done: stats.done + points}
          _ -> %{stats | todo: stats.todo + points}
        end
    end
  end

  defp get_date(date) do
    date
    |> String.replace(~r/T.*/, "")
    |> Date.from_iso8601!()
  end
end
