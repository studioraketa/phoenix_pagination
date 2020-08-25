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
  # select count.
  defp prep_for_count(%{distinct: term} = queryable) when term == true or is_list(term) do
    queryable
    |> exclude(:select)
    |> subquery()
  end

  defp prep_for_count(%{group_bys: _term} = queryable), do: subquery(queryable)

  defp prep_for_count(queryable), do: exclude(queryable, :select)
end
