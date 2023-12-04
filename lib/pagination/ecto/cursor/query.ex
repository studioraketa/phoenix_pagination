defmodule Pagination.Ecto.Cursor.Query do
  import Ecto.Query

  alias Pagination.Ecto.Cursor.Options

  def assert_cursor_pagination_available!(%Ecto.Query{order_bys: order_bys, group_bys: group_bys}) do
    if !Enum.empty?(order_bys) do
      raise "Cannot cursor-paginate ordered query."
    end

    if !Enum.empty?(group_bys) do
      raise "Cannot cursor-paginate grouped query."
    end
  end

  def assert_cursor_pagination_available!(_), do: :ok

  def entries(queryable, %Options{} = opts) do
    queryable
    |> add_filtering(opts)
    |> add_ordering(opts)
    |> Ecto.Query.limit(^opts.page_size)
    |> opts.repo.all()
  end

  defp add_filtering(queryable, opts) do
    case comp_op(opts.direction) do
      :< ->
        lt_filter(queryable, opts)
      :> ->
        gt_filter(queryable, opts)
    end
  end

  defp gt_filter(queryable, %{cursor: nil} = _opts), do: queryable

  defp gt_filter(queryable, opts) do
    from(
      q in queryable,
      where: field(q, ^opts.field) > ^opts.cursor
    )
  end

  defp lt_filter(queryable, %{cursor: nil} = _opts), do: queryable

  defp lt_filter(queryable, opts) do
    from(
      q in queryable,
      where: field(q, ^opts.field) < ^opts.cursor
    )
  end

  defp add_ordering(queryable, opts) do
    from(
      q in queryable,
      order_by: [{^opts.direction, field(q, ^opts.field)}]
    )
  end

  defp comp_op(:desc), do: :<
  defp comp_op(:desc_nulls_last), do: :<
  defp comp_op(:desc_nulls_first), do: :<
  defp comp_op(:asc), do: :>
  defp comp_op(:asc_nulls_last), do: :>
  defp comp_op(:asc_nulls_first), do: :>
  defp comp_op(_), do: :>
end
