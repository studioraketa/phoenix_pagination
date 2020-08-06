defmodule Pagination.EctoTest do
  use Pagination.TestCase

  alias Pagination.Test.{Repo, Post, User}

  def create_user do
    %User{name: "John Doe"} |> Repo.insert!()
  end

  def create_post(user) do
    %Post{user_id: user.id, title: "A Post", content: "Some very insightful stuff here."}
    |> Repo.insert!()
  end

  def create_posts do
    user = create_user()
    Enum.map(1..100, fn _num -> create_post(user) end)
  end

  def create_users_with_posts do
    Enum.map(1..20, fn _num ->
      user = create_user()
      posts = Enum.map(1..20, fn _num -> create_post(user) end)
      %User{user | posts: posts}
    end)
  end

  describe "pagination" do
    test "paginate/1 paginate a query using the defaults" do
      posts = create_posts()

      %Pagination.Ecto.List{} = list = Repo.paginate(Post)

      assert list.entries_count == 100
      assert list.page_size == 5
      assert list.pages_count == 20
      assert list.current_page == 1
      assert list.entries == Enum.take(posts, 5)
    end

    test "paginate/1 generate list result for non exitent entries" do
      %Pagination.Ecto.List{} = list = Repo.paginate(Post)

      assert list.entries_count == 0
      assert list.page_size == 5
      assert list.pages_count == 0
      assert list.current_page == 1
      assert list.entries == []
    end

    test "paginate/1 paginate a query using the input page and page_size" do
      posts = create_posts()

      %Pagination.Ecto.List{} = list = Repo.paginate(Post, %{"page" => 2, "page_size" => 3})

      assert list.entries_count == 100
      assert list.page_size == 3
      assert list.pages_count == 34
      assert list.current_page == 2
      assert list.entries == posts |> Enum.take(6) |> Enum.chunk_every(3) |> List.last()
    end

    test "paginate/1 paginates with preloads" do
      users = create_users_with_posts()

      %Pagination.Ecto.List{} = list =
        from(user in User, where: ilike(user.name, "%John%"))
        |> preload(:posts)
        |> Repo.paginate(%{"page" => 2, "page_size" => 3})

      assert list.entries_count == 20
      assert list.page_size == 3
      assert list.pages_count == 7
      assert list.current_page == 2
      assert list.entries == users |> Enum.take(6) |> Enum.chunk_every(3) |> List.last()
      refute List.first(list.entries).posts == []
    end
  end
end
