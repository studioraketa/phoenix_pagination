defmodule Pagination.Ecto.Cursor.OptionsTest do
  use ExUnit.Case

  alias Pagination.Ecto.Cursor.Options

  defmodule FakeRepo do
  end

  test "build/1 with complete params set - atom keys" do
    params = %{page_size: 15, field: :inserted_at, direction: :asc}
    defaults = [page_size: 10, field: :id, direction: :desc]

    assert %Options{
      page_size: 15, field: :inserted_at, direction: :asc, cursor: nil, repo: FakeRepo,
    } = Options.build(params, FakeRepo, defaults)
  end

  test "build/1 with complete params set - string keys" do
    params = %{"page_size" => "15", "field" => :inserted_at, "direction" => :asc}
    defaults = [page_size: 10, field: :id, direction: :desc]

    assert %Options{
      page_size: 15, field: :inserted_at, direction: :asc, cursor: nil, repo: FakeRepo,
    } = Options.build(params, FakeRepo, defaults)
  end

  test "build/1 missing page size - atom keys" do
    params = %{field: :inserted_at, direction: :asc}
    defaults = [page_size: 10, field: :id, direction: :desc]

    assert %Options{
      page_size: 10, field: :inserted_at, direction: :asc, cursor: nil, repo: FakeRepo,
    } = Options.build(params, FakeRepo, defaults)
  end

  test "build/1 missing page size - string keys" do
    params = %{"field" => :inserted_at, "direction" => :asc}
    defaults = [page_size: 10, field: :id, direction: :desc]

    assert %Options{
      page_size: 10, field: :inserted_at, direction: :asc, cursor: nil, repo: FakeRepo,
    } = Options.build(params, FakeRepo, defaults)
  end

  test "build/1 missing field - atom keys" do
    params = %{page_size: 15, direction: :asc}
    defaults = [page_size: 10, field: :id, direction: :desc]

    assert %Options{
      page_size: 15, field: :id, direction: :asc, cursor: nil, repo: FakeRepo,
    } = Options.build(params, FakeRepo, defaults)
  end

  test "build/1 missing field - string keys" do
    params = %{"page_size" => 15, "direction" => :asc}
    defaults = [page_size: 10, field: :id, direction: :desc]

    assert %Options{
      page_size: 15, field: :id, direction: :asc, cursor: nil, repo: FakeRepo,
    } = Options.build(params, FakeRepo, defaults)
  end

  test "build/1 missing direction - atom keys" do
    params = %{page_size: 15, field: :inserted_at}
    defaults = [page_size: 10, field: :id, direction: :desc]

    assert %Options{
      page_size: 15, field: :inserted_at, direction: :desc, cursor: nil, repo: FakeRepo,
    } = Options.build(params, FakeRepo, defaults)
  end

  test "build/1 missing direction - string keys" do
    params = %{"page_size" => 15, "field" => :inserted_at}
    defaults = [page_size: 10, field: :id, direction: :desc]

    assert %Options{
      page_size: 15, field: :inserted_at, direction: :desc, cursor: nil, repo: FakeRepo,
    } = Options.build(params, FakeRepo, defaults)
  end
end
