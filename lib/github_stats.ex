defmodule GithubStats do
  # def burndown(repo, milestone, start_date, end_date) do
  def burndown(repo) do
    # GithubAPI.get(repo, "issues", milestone: milestone, per_page: 2)
    # TODO: full query, move to other file, process resposne
    query = """
      query getIssues($owner: String!, $repository: String!) {
        repository(name: $repository, owner: $owner) {
          id
          name
        }
      }
    """

    GithubAPI.call_github(query, %{repository: repo})
  end
end

# Desired interface:
# [BOT_NAME] [CHART_NAME] [REPO_NAME] ...[OPTIONS]
#
# Burndown Example:
# GHS burndown docs-website 1 2020-09-01 2020-09-15
# Options: [MILESTONE_ID] [START_DATE] [END_DATE]
