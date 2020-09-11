defmodule GithubStats do
  # TODO: map dates to data set
  # TODO: produce image
  def burndown(repo, milestone) do
    {:burndown, vars: %{repository: repo, milestone: milestone}}
    |> GithubAPI.query_github()
  end
end

# Desired interface:
# [BOT_NAME] [CHART_NAME] [REPO_NAME] ...[OPTIONS]
#
# Burndown Example:
# GHS burndown docs-website 1 2020-09-01 2020-09-15
# Options: [MILESTONE_ID] [START_DATE] [END_DATE]
