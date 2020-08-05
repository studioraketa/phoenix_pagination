defmodule Pagination.Html.Navigation do
  alias Pagination.Ecto.List

  @peripheral_links_count 2
  @surround_links_count 3

  def elements(%List{current_page: current_page} = list) do
    before_current_page(list) ++ [current_page | after_current_page(list)]
  end

  defp before_current_page(%List{current_page: 1}), do: []
  defp before_current_page(%List{current_page: current_page, pages_count: pages_count}) do
    1..(current_page - 1)
    |> Enum.to_list()
    |> Enum.map(fn page -> page_value(page, current_page, pages_count) end)
    |> Enum.uniq()
  end

  defp after_current_page(%List{current_page: current_page, pages_count: current_page}), do: []
  defp after_current_page(%List{current_page: current_page, pages_count: pages_count}) do
    (current_page + 1)..pages_count
    |> Enum.to_list()
    |> Enum.map(fn page -> page_value(page, current_page, pages_count) end)
    |> Enum.uniq()
  end

  defp page_value(page, current_page, _pages_count) when page < current_page do
    cond do
      page >= current_page - @surround_links_count ->
        page
      page <= @peripheral_links_count ->
        page
      page > @peripheral_links_count && page < current_page - @surround_links_count ->
        "..."
    end
  end

  defp page_value(page, current_page, pages_count) when page > current_page do
    cond do
      page <= current_page + @surround_links_count ->
        page
      page > pages_count - @peripheral_links_count ->
        page
      page <= pages_count - @peripheral_links_count && page > current_page + @surround_links_count ->
        "..."
    end
  end

  defp page_value(_page, current_page, _pages_count), do: current_page
end
