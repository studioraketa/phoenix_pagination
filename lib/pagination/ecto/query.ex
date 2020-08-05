defmodule Pagination.Ecto.Query do
  import Ecto.Query

  alias Pagination.Ecto.Options

  def entries(queryable, %Options{} = opts) do
    queryable
    |> Ecto.Query.limit(^opts.page_size)
    |> Ecto.Query.offset(^opts.offset)
    |> opts.repo.all()
  end

  def total_count(queryable, %Options{} = opts) do
    queryable
    |> exclude(:preload)
    |> exclude(:select)
    |> exclude(:order_by)
    |> select(count("*"))
    |> opts.repo.one
  end
end
