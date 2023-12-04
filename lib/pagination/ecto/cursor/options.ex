defmodule Pagination.Ecto.Cursor.Options do
  import Pagination.Utils

  @type t :: %__MODULE__{}

  @keys [:cursor, :page_size, :repo, :field, :direction]
  @enforce_keys @keys
  defstruct @keys

  def build(params, repo, defaults) do
    %__MODULE__{
      page_size: to_i(get(params, :page_size, defaults)),
      cursor: get(params, :cursor),
      field: get(params, :field, defaults),
      direction: get(params, :direction, defaults),
      repo: repo
    }
  end
end
