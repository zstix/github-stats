defmodule GithubStats.Application do
  @moduledoc false

  use Application

  # run with `mix run --no-halt`
  def start(_type, _args) do
    port = 4000

    children = [
      {Plug.Cowboy, scheme: :http, plug: GithubStats.Router, options: [port: port]}
    ]

    IO.puts("Starting server on port #{port}")

    opts = [strategy: :one_for_one, name: GithubStats.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
