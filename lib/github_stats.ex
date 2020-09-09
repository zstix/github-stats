defmodule GithubStats do
  import GithubAPI

  # def burndown(repo, milestone, start_date, end_date) do
  def burndown(repo) do
    # TODO: add filters for milestone
    options = [per_page: 1]

    get_url(repo, "issues", options)
    |> fetch()
    |> process_results()

    # TODO: get stats
  end

  # TODO clean up and move elsewhere
  defp process_results({:ok, results}) do
    results
    |> Enum.map(fn %{title: title} -> title end)
  end
end

# Desired interface:
# [BOT_NAME] [CHART_NAME] [REPO_NAME] ...[OPTIONS]
#
# Burndown Example:
# GHS burndown docs-website 1 2020-09-01 2020-09-15
# Options: [MILESTONE_ID] [START_DATE] [END_DATE]
