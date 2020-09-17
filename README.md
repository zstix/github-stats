# Github Stats

Queries GitHub's API to help us build productivity charts. Currently supports burndown charts for milestones in public New Relic repositories.

## Usage

[https://github-stats.gigalixirapp.com/burndown](https://github-stats.gigalixirapp.com/burndown)

**URL Parameters**

| Key          | Format     | Description                                         |
| ------------ | ---------- | --------------------------------------------------- |
| `repo`       | string     | The repository name                                 |
| `milestone`  | number     | The milestone _number_ (can be found from it's URL) |
| `start_date` | YYYY-MM-DD | The start date for the chart                        |
| `end_date`   | YYYY-MM-DD | The end date for the chart                          |

**Example**

[https://github-stats.gigalixirapp.com/burndown?repo=docs-website&milestone=1&start_date=2020-08-18&end_date=2020-09-02](https://github-stats.gigalixirapp.com/burndown?repo=docs-website&milestone=1&start_date=2020-08-18&end_date=2020-09-02)
