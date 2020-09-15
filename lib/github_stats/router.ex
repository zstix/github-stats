defmodule GithubStats.Router do
  use Plug.Router

  plug(:match)
  plug(Plug.Parsers, parsers: [:json, :urlencoded], json_decoder: Jason)
  plug(:dispatch)

  # TODO: send SVG back
  # TODO: ensure headers are SVG
  get "/burndown" do
    conn
    |> get_missing_params(["repo", "milestone", "start_date", "end_date"])
    |> case do
      {conn, ""} -> send_resp(conn, 200, "Good")
      {conn, missing} -> send_resp(conn, 400, "Missing: #{missing}")
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  defp get_missing_params(conn, keys) do
    {
      conn,
      keys
      |> Enum.filter(&(!Map.has_key?(conn.query_params, &1)))
      |> Enum.join(", ")
    }
  end
end
