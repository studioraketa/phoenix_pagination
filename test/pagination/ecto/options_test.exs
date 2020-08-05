defmodule Pagination.Ecto.OptionsTest do
  use ExUnit.Case

  alias Pagination.Ecto.Options

  defmodule FakeRepo do
  end

  test "build/1 with complete params set - atom keys" do
    params = %{page_size: 15, page: 2}
    defaults = [page_size: 10, page: 1]

    assert %Options{
      page_size: 15, page: 2, repo: FakeRepo, offset: 15
    } = Options.build(params, FakeRepo, defaults)
  end

  test "build/1 with complete params set - string keys" do
    params = %{"page_size" => 15, "page" => 5}
    defaults = [page_size: 10, page: 1]

    assert %Options{
      page_size: 15, page: 5, repo: FakeRepo, offset: 60
    } = Options.build(params, FakeRepo, defaults)
  end

  test "build/1 missing page size - atom keys" do
    params = %{page: 5}
    defaults = [page_size: 10, page: 1]

    assert %Options{
      page_size: 10, page: 5, repo: FakeRepo, offset: 40
    } = Options.build(params, FakeRepo, defaults)
  end

  test "build/1 missing page size - string keys" do
    params = %{"page" => 5}
    defaults = [page_size: 10, page: 1]

    assert %Options{
      page_size: 10, page: 5, repo: FakeRepo, offset: 40
    } = Options.build(params, FakeRepo, defaults)
  end

  test "build/1 missing page - atom keys" do
    params = %{page_size: 5}
    defaults = [page_size: 10, page: 1]

    assert %Options{
      page_size: 5, page: 1, repo: FakeRepo, offset: 0
    } = Options.build(params, FakeRepo, defaults)
  end

  test "build/1 missing page - string keys" do
    params = %{"page_size" => 5}
    defaults = [page_size: 10, page: 1]

    assert %Options{
      page_size: 5, page: 1, repo: FakeRepo, offset: 0
    } = Options.build(params, FakeRepo, defaults)
  end
end
