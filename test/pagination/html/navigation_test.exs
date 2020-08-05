defmodule Pagination.Html.NavigationTest do
  use ExUnit.Case

  alias Pagination.Html.Navigation
  alias Pagination.Ecto.List

  test "elements/1 with a page at the first place of 10 pages" do
    list = %List{
      entries: [],
      current_page: 1,
      page_size: 10,
      entries_count: 100,
      pages_count: 10
    }

    assert [1, 2, 3, 4, "...", 9, 10] == Navigation.elements(list)
  end

  test "elements/1 with a page at the last place of 10 pages" do
    list = %List{
      entries: [],
      current_page: 10,
      page_size: 10,
      entries_count: 100,
      pages_count: 10
    }

    assert [1, 2, "...", 7, 8, 9, 10] == Navigation.elements(list)
  end

  test "elements/1 with a page in the middle of 20 pages" do
    list = %List{
      entries: [],
      current_page: 12,
      page_size: 10,
      entries_count: 200,
      pages_count: 20
    }

    assert [1, 2, "...", 9, 10, 11, 12, 13, 14, 15, "...", 19, 20] == Navigation.elements(list)
  end

  test "elements/1 with the complete navigation visible" do
    list = %List{
      entries: [],
      current_page: 6,
      page_size: 10,
      entries_count: 100,
      pages_count: 10
    }

    assert [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] == Navigation.elements(list)
  end

  test "elements/1 with the complete navigation almost visible" do
    list = %List{
      entries: [],
      current_page: 7,
      page_size: 10,
      entries_count: 130,
      pages_count: 13
    }

    assert [1, 2, "...", 4, 5, 6, 7, 8, 9, 10, "...", 12, 13] == Navigation.elements(list)
  end
end
