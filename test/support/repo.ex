defmodule Pagination.Test.Repo do
  use Ecto.Repo, otp_app: :phoenix_pagination, adapter: Ecto.Adapters.Postgres

  use Pagination.Ecto, page_size: 5, cursor_page_size: 5
end
