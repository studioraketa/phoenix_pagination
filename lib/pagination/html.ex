defmodule Pagination.Html do
  use Phoenix.HTML

  alias Pagination.Ecto.List
  alias Pagination.Html.Navigation

  def paginate_list(%List{} = list, path_fn, opts \\ []) do
    generate_pagination(list, path_fn, opts)
  end

  defp generate_pagination(%List{entries_count: 0} = _list, _path_fn, _opts), do: ""
  defp generate_pagination(%List{page_size: page_size, entries_count: entries_count} = _list, _path_fn, _opts)
    when entries_count <= page_size do
      ""
    end
  defp generate_pagination(%List{current_page: current_page, pages_count: pages_count} = _list, _path_fn, _opts)
    when current_page > pages_count do
      ""
    end

  defp generate_pagination(%List{} = list, path_fn, opts) do
    content_tag(:nav, class: "pagination") do
      [previous(list, path_fn, opts)] ++ middle(list, path_fn, opts) ++ [next(list, path_fn, opts)]
    end
  end

  defp middle(%List{current_page: current_page} = list, path_fn, opts) do
    list
    |> Navigation.elements()
    |> Enum.map(
        fn
          "..." = page ->
            content_tag(:em) do
              Keyword.get(opts, :etc_label, page)
            end
          page ->
            case page == current_page do
              true ->
                content_tag(:em, class: "current-page") do
                  page
                end
              false ->
                content_tag(:a, href: path_fn.(page)) do
                  page
                end
            end
        end
      )
  end

  defp previous(%List{current_page: 1} = _list, _path_fn, opts) do
    content_tag(:em) do
      previous_label(opts)
    end
  end

  defp previous(%List{current_page: page} = _list, path_fn, opts) do
    content_tag(:a, href: path_fn.(page - 1)) do
      previous_label(opts)
    end
  end

  defp previous_label(opts) do
    Keyword.get(opts, :previous_label, "Previous")
  end

  defp next(%List{current_page: page, pages_count: page} = _list, _path_fn, opts) do
    content_tag(:em) do
      next_label(opts)
    end
  end

  defp next(%List{current_page: page} = _list, path_fn, opts) do
    content_tag(:a, href: path_fn.(page + 1)) do
      next_label(opts)
    end
  end

  defp next_label(opts) do
    Keyword.get(opts, :next_label, "Next")
  end
end
