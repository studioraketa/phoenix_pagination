defmodule Pagination.Ecto.Offset.Options do
  import Pagination.Utils

  @type t :: %__MODULE__{}

  @keys [:page, :page_size, :offset, :repo]
  @enforce_keys @keys
  defstruct @keys

  def build(params, repo, defaults) do
    %__MODULE__{
      page_size: to_i(get(params, :page_size, defaults)),
      page: to_i(get(params, :page, defaults)),
      offset: offset(params, defaults),
      repo: repo
    }
  end

  defp offset(params, defaults) do
    (to_i(get(params, :page, defaults)) - 1) * to_i(get(params, :page_size, defaults))
  end
end
