defmodule GithubStats.Router do
  use Plug.Router

  plug(:match)
  plug(Plug.Parsers, parsers: [:json, :urlencoded], json_decoder: Jason)
  plug(:dispatch)

  # TODO: clean this up
  # TODO: send SVG back
  # TODO: ensure headers are SVG
  get "/burndown" do
    {code, resp} =
      cond do
        validate_request({:burndown, conn.query_params}) -> {200, "Good"}
        true -> {400, "Bad Response"}
      end

    send_resp(conn, code, resp)

    # GithubStats.burndown(repo, milestone, start_date, end_date)
    # send_resp(conn, 200, "world")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  defp validate_request({:burndown, params}) do
    validate_request(["repo", "milestone", "start_date", "end_date"], params)
  end

  defp validate_request(keys, params) do
    Enum.all?(keys, &Map.has_key?(params, &1))
  end
end
