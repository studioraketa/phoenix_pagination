use Mix.Config

config :phoenix_pagination, ecto_repos: [Pagination.Test.Repo]

config :phoenix_pagination, Pagination.Test.Repo,
  priv: "test/support/priv/repo",
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  username: "postgres",
  password: "postgres",
  database: "phoenix_pagination_test",
  hostname: "localhost",
  pool_size: 10

config :logger, :console, level: :error
# config :logger, :console, format: "[$level] $message\n"
