defmodule Pagination.HtmlTest do
  use ExUnit.Case

  alias Pagination.Html
  alias Pagination.Ecto.Offset.List

  test "paginate_list/1 when entries_count is 0" do
    list = %List{
      entries: [],
      current_page: 1,
      page_size: 10,
      entries_count: 0,
      pages_count: 0
    }

    path_fn = fn x -> IO.puts(x) end

    assert "" == Html.paginate_list(list, path_fn, [])
  end

  test "paginate_list/1 when entries_count is 0 using default options" do
    list = %List{
      entries: [],
      current_page: 1,
      page_size: 10,
      entries_count: 0,
      pages_count: 0
    }

    path_fn = fn x -> IO.puts(x) end

    assert "" == Html.paginate_list(list, path_fn)
  end

  test "paginate_list/1 when total count is less or equal to page size" do
    list = %List{
      entries: [],
      current_page: 1,
      page_size: 10,
      entries_count: 5,
      pages_count: 1
    }

    path_fn = fn x -> IO.puts(x) end

    assert "" == Html.paginate_list(list, path_fn, [])
  end

  test "paginate_list/1 when current page is outside of the scope" do
    list = %List{
      entries: [],
      current_page: 20,
      page_size: 10,
      entries_count: 5,
      pages_count: 1
    }

    path_fn = fn x -> IO.puts(x) end

    assert "" == Html.paginate_list(list, path_fn, [])
  end

  test "paginate_list/1 when the current page is page 1" do
    list = %List{
      entries: [],
      current_page: 1,
      page_size: 3,
      entries_count: 9,
      pages_count: 3
    }

    path_fn = fn x -> "/path/#{x}" end

    result = Phoenix.HTML.safe_to_string(Html.paginate_list(list, path_fn, []))

    assert result == "<nav class=\"pagination\"><em>Previous</em><em class=\"current-page\">1</em><a href=\"/path/2\">2</a><a href=\"/path/3\">3</a><a href=\"/path/2\">Next</a></nav>"
  end

  test "paginate_list/1 when the current page is in the middle" do
    list = %List{
      entries: [],
      current_page: 2,
      page_size: 3,
      entries_count: 9,
      pages_count: 3
    }

    path_fn = fn x -> "/path/#{x}" end

    result = Phoenix.HTML.safe_to_string(Html.paginate_list(list, path_fn, []))

    assert result == "<nav class=\"pagination\"><a href=\"/path/1\">Previous</a><a href=\"/path/1\">1</a><em class=\"current-page\">2</em><a href=\"/path/3\">3</a><a href=\"/path/3\">Next</a></nav>"
  end

  test "paginate_list/1 when the current page is in the middle with given previous label" do
    list = %List{
      entries: [],
      current_page: 2,
      page_size: 3,
      entries_count: 9,
      pages_count: 3
    }

    path_fn = fn x -> "/path/#{x}" end

    result = Phoenix.HTML.safe_to_string(Html.paginate_list(list, path_fn, [previous_label: "<-"]))

    assert result == "<nav class=\"pagination\"><a href=\"/path/1\">&lt;-</a><a href=\"/path/1\">1</a><em class=\"current-page\">2</em><a href=\"/path/3\">3</a><a href=\"/path/3\">Next</a></nav>"
  end

  test "paginate_list/1 when the current page is in the middle with given next label" do
    list = %List{
      entries: [],
      current_page: 2,
      page_size: 3,
      entries_count: 9,
      pages_count: 3
    }

    path_fn = fn x -> "/path/#{x}" end

    result = Phoenix.HTML.safe_to_string(Html.paginate_list(list, path_fn, [next_label: "->"]))

    assert result == "<nav class=\"pagination\"><a href=\"/path/1\">Previous</a><a href=\"/path/1\">1</a><em class=\"current-page\">2</em><a href=\"/path/3\">3</a><a href=\"/path/3\">-&gt;</a></nav>"
  end

  test "paginate_list/1 when the current page is in the middle with given etc label" do
    list = %List{
      entries: [],
      current_page: 8,
      page_size: 3,
      entries_count: 30,
      pages_count: 10
    }

    path_fn = fn x -> "/path/#{x}" end

    result = Phoenix.HTML.safe_to_string(Html.paginate_list(list, path_fn, [etc_label: "etc"]))

    assert result == "<nav class=\"pagination\"><a href=\"/path/7\">Previous</a><a href=\"/path/1\">1</a><a href=\"/path/2\">2</a><em>etc</em><a href=\"/path/5\">5</a><a href=\"/path/6\">6</a><a href=\"/path/7\">7</a><em class=\"current-page\">8</em><a href=\"/path/9\">9</a><a href=\"/path/10\">10</a><a href=\"/path/9\">Next</a></nav>"
  end

  test "paginate_list/1 when the current page is the last page" do
    list = %List{
      entries: [],
      current_page: 3,
      page_size: 3,
      entries_count: 9,
      pages_count: 3
    }

    path_fn = fn x -> "/path/#{x}" end

    result = Phoenix.HTML.safe_to_string(Html.paginate_list(list, path_fn, []))

    assert result == "<nav class=\"pagination\"><a href=\"/path/2\">Previous</a><a href=\"/path/1\">1</a><a href=\"/path/2\">2</a><em class=\"current-page\">3</em><em>Next</em></nav>"
  end
end
