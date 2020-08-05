defmodule Pagination.Ecto.Options do
  @type t :: %__MODULE__{}

  @keys [:page, :page_size, :offset, :repo]
  @enforce_keys @keys
  defstruct @keys

  def build(params, repo, defaults) do
    %__MODULE__{
      page_size: to_i(page_size(params, defaults)),
      page: to_i(page(params, defaults)),
      offset: offset(params, defaults),
      repo: repo
    }
  end

  defp maybe_nil(""), do: nil
  defp maybe_nil(value), do: value

  defp page_size(params, defaults) do
    maybe_nil(params[:page_size]) ||
      maybe_nil(params["page_size"]) ||
      Keyword.fetch!(defaults, :page_size)
  end

  defp page(params, defaults) do
    maybe_nil(params[:page]) ||
      maybe_nil(params["page"]) ||
      Keyword.fetch!(defaults, :page)
  end

  defp offset(params, defaults) do
    (to_i(page(params, defaults)) - 1) * to_i(page_size(params, defaults))
  end

  defp to_i(num) when is_binary(num), do: String.to_integer(num)
  defp to_i(num) when is_integer(num), do: num
end
