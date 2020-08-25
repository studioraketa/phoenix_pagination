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
    |> exclude(:order_by)
    |> exclude(:select)
    |> handle_distinct()
    |> select(count("*"))
    |> opts.repo.one
  end

  # When having a distinct in the query do a subquery from the original query and then
  # select count.
  defp handle_distinct(%{distinct: _expr} = queryable) do
    subquery(queryable)
  end

  defp handle_distinct(queryable), do: queryable
end
