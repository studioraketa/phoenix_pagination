defmodule Pagination.Ecto.Offset.List do
  @moduledoc false

  alias Pagination.Ecto.Offset.{Options, Query}

  @type t :: %__MODULE__{}

  @keys [:entries, :current_page, :page_size, :entries_count, :pages_count]
  @enforce_keys @keys
  defstruct @keys

  def build(queryable, %Options{} = opts) do
    entries_count = Query.total_count(queryable, opts)
    pages_count = calculate_pages_count(entries_count, opts.page_size)

    %__MODULE__{
      entries: list_entries(queryable, entries_count, opts),
      current_page: opts.page,
      page_size: opts.page_size,
      entries_count: entries_count,
      pages_count: pages_count
    }
  end

  defp calculate_pages_count(entries_count, page_size) do
    entries_count
    |> Decimal.div(page_size)
    |> Decimal.round(0, :ceiling)
    |> Decimal.to_integer()
  end

  defp list_entries(_queryable, 0, _opts), do: []
  defp list_entries(queryable, _entries_count, opts) do
    Query.entries(queryable, opts)
  end
end
