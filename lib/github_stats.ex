defmodule GithubStats do
  import GithubAPI

  def burndown(repo, milestone, start_date, end_date) do
    # TODO: construct correct URL
    get_url(repo, "issues")
    |> fetch()

    # TODO: get stats
  end
end

# Desired interface:
# [BOT_NAME] [CHART_NAME] [REPO_NAME] ...[OPTIONS]
#
# Burndown Example:
# GHS burndown docs-website 1 2020-09-01 2020-09-15
# Options: [MILESTONE_ID] [START_DATE] [END_DATE]
