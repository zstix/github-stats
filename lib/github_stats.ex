defmodule GithubStats do
  def burndown(
        _repo \\ "dev-website",
        _milestone \\ 2,
        _start_date \\ "2020-09-03",
        _end_date \\ "2020-09-15"
      ) do
    %{
      title: "MMF 3 - Getting Started",
      data: [
        %{date: ~D[2020-05-19], todo: 23, in_progress: 15, in_review: 3, done: 0},
        %{date: ~D[2020-05-20], todo: 23, in_progress: 15, in_review: 3, done: 0},
        %{date: ~D[2020-05-21], todo: 20, in_progress: 10, in_review: 8, done: 3},
        %{date: ~D[2020-05-22], todo: 20, in_progress: 8, in_review: 0, done: 13},
        %{date: ~D[2020-05-26], todo: 20, in_progress: 8, in_review: 0, done: 13},
        %{date: ~D[2020-05-27], todo: 20, in_progress: 8, in_review: 0, done: 13},
        %{date: ~D[2020-05-28], todo: 0, in_progress: 0, in_review: 0, done: 0},
        %{date: ~D[2020-05-29], todo: 0, in_progress: 0, in_review: 0, done: 0},
        %{date: ~D[2020-06-01], todo: 0, in_progress: 0, in_review: 0, done: 0},
        %{date: ~D[2020-06-02], todo: 0, in_progress: 0, in_review: 0, done: 0}
      ]
    }
    |> GithubCharts.draw_chart(:burndown)

    # {:burndown, vars: %{repository: repo, milestone: milestone}}
    # |> GithubAPI.query_github(start_date, end_date)
    # |> GithubCharts.draw_chart(:burndown)
  end
end

# Desired interface:
# [BOT_NAME] [CHART_NAME] [REPO_NAME] ...[OPTIONS]
#
# Burndown Example:
# GHS burndown docs-website 2 2020-09-03 2020-09-15
# Options: [MILESTONE_ID] [START_DATE] [END_DATE]
