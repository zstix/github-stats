import Config

config :github_stats, GithubStats.Application,
  server: true,
  http: [port: {:system, "PORT"}],
  url: [host: nil, port: 443]
