defmodule GithubStats.Router do
  use Plug.Router

  plug(:match)
  plug(Plug.Parsers, parsers: [:json, :urlencoded], json_decoder: Jason)
  plug(:dispatch)

  # TODO: post endpoint for slack

  get "/burndown" do
    conn
    |> get_missing_params(["repo", "milestone", "start_date", "end_date"])
    |> case do
      "" ->
        conn
        |> put_resp_content_type("image/svg+xml")
        |> send_resp(200, get_resp({:burndown, conn.query_params}))

      missing ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(400, "Missing: #{missing}")
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  defp get_missing_params(conn, keys) do
    keys
    |> Enum.filter(&(!Map.has_key?(conn.query_params, &1)))
    |> Enum.join(", ")
  end

  defp get_resp({:burndown, params}) do
    %{
      "repo" => repo,
      "milestone" => milestone,
      "start_date" => start_date,
      "end_date" => end_date
    } = params

    {:burndown, vars: %{repository: repo, milestone: String.to_integer(milestone)}}
    |> GithubStats.Query.query_github(start_date, end_date)
    |> GithubStats.Charts.draw_chart(:burndown)
  end
end
