defmodule GithubStats do
  def burndown(
        repo \\ "docs-website",
        milestone \\ 2,
        start_date \\ "2020-09-03",
        end_date \\ "2020-09-15"
      ) do
    {:burndown, vars: %{repository: repo, milestone: milestone}}
    |> GithubAPI.query_github(start_date, end_date)
    |> GithubCharts.draw_chart(:burndown)
  end
end

# Desired interface:
# [BOT_NAME] [CHART_NAME] [REPO_NAME] ...[OPTIONS]
#
# Burndown Example:
# GHS burndown docs-website 2 2020-09-03 2020-09-15
# Options: [MILESTONE_ID] [START_DATE] [END_DATE]
