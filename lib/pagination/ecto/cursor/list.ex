defmodule Pagination.Ecto.Cursor.List do
  @moduledoc false

  alias Pagination.Ecto.Cursor.{Options, Query}

  @keys [:entries, :cursor, :page_size]
  @enforce_keys @keys
  defstruct @keys

  @type t :: %__MODULE__{}

  def build(queryable, %Options{} = opts) do
    to_list(Query.entries(queryable, opts), opts)
  end

  defp to_list([], opts) do
    %__MODULE__{
      entries: [],
      cursor: nil,
      page_size: opts.page_size
    }
  end

  defp to_list(entries, opts) do
    if Enum.count(entries) > opts.page_size do
      entr = Enum.take(entries, opts.page_size)
      last = List.last(entr)

      %__MODULE__{
        entries: entr,
        cursor: encode_cursor(Map.get(last, opts.field)),
        page_size: opts.page_size
      }
    else
      %__MODULE__{
        entries: entries,
        cursor: nil,
        page_size: opts.page_size
      }
    end
  end

  defp encode_cursor(nil), do: nil
  defp encode_cursor(cursor) do
    Base.url_encode64(to_string(cursor))
  end
end
