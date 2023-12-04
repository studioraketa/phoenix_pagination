defmodule Pagination.Ecto.Cursor.Options do
  import Pagination.Utils

  @type t :: %__MODULE__{}

  @keys [:cursor, :page_size, :repo, :field, :direction]
  @enforce_keys @keys
  defstruct @keys

  def build(params, repo, defaults) do
    %__MODULE__{
      page_size: to_i(get(params, :page_size, defaults)),
      cursor: decode_cursor(get(params, :cursor)),
      field: get(params, :field, defaults),
      direction: get(params, :direction, defaults),
      repo: repo
    }
  end

  defp decode_cursor(nil), do: nil
  defp decode_cursor(cursor) do
    Base.url_decode64!(cursor)
  end
end
