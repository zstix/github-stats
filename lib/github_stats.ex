defmodule GithubStats do
  # TODO: process response
  # TODO: timeline
  # TODO: map dates to data set
  def burndown(repo, milestone) do
    GithubAPI.query_github({
      :burndown,
      vars: %{
        repository: repo,
        milestone: milestone
      }
    })
  end
end

# Desired interface:
# [BOT_NAME] [CHART_NAME] [REPO_NAME] ...[OPTIONS]
#
# Burndown Example:
# GHS burndown docs-website 1 2020-09-01 2020-09-15
# Options: [MILESTONE_ID] [START_DATE] [END_DATE]
