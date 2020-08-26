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
    |> prep_for_count()
    |> select(count("*"))
    |> opts.repo.one
  end

  # When having a distinct in the query do a subquery from the original query and then
  # select count the results.
  defp prep_for_count(%{distinct: %Ecto.Query.QueryExpr{} = _expr} = queryable) do
    queryable
    |> exclude(:select)
    |> subquery()
  end

  # When having a group by in the query do a subquery from the original query and then
  # select count to count the results.
  defp prep_for_count(%{group_bys: [%Ecto.Query.QueryExpr{} = _expr]} = queryable) do
    subquery(queryable)
  end

  defp prep_for_count(queryable) do
    exclude(queryable, :select)
  end
end
