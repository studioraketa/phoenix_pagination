defmodule Pagination.EctoTest do
  use Pagination.TestCase

  alias Pagination.Test.{Repo, Post, User, Tag, PostTag}

  def create_user do
    %User{name: "John Doe"} |> Repo.insert!()
  end

  def create_post(user) do
    %Post{user_id: user.id, title: "A Post", content: "Some very insightful stuff here."}
    |> Repo.insert!()
  end

  def create_tag(slug), do: %Tag{slug: slug} |> Repo.insert!()

  def create_posts do
    user = create_user()
    Enum.map(1..100, fn _num -> create_post(user) end)
  end

  def create_post_tag(post, tag) do
    %PostTag{post_id: post.id, tag_id: tag.id} |> Repo.insert!()
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

    test "paginate/1 works with a query containing distinct" do
      posts = create_posts()

      %Pagination.Ecto.List{} = list =
        Post
        |> order_by(asc: :id)
        |> distinct(true)
        |> Repo.paginate(%{"page" => 2, "page_size" => 3})

      assert list.entries_count == 100
      assert list.page_size == 3
      assert list.pages_count == 34
      assert list.current_page == 2
      assert list.entries == posts |> Enum.take(6) |> Enum.chunk_every(3) |> List.last()
    end

    test "paginate/1 works with a join query containing distinct" do
      posts = create_posts()
      green = create_tag("green")
      blue = create_tag("blue")

      Enum.each(
        posts,
        fn post ->
          create_post_tag(post, green)
          create_post_tag(post, blue)
        end
      )

      query = from(
        post in Post,
        join: pt in "post_tags",
        on: post.id == pt.post_id,
        where: pt.tag_id in ^[green.id, blue.id],
        distinct: post.id
      )

      %Pagination.Ecto.List{} = list = Repo.paginate(query, %{"page" => 2, "page_size" => 3})

      assert list.entries_count == 100
      assert list.page_size == 3
      assert list.pages_count == 34
      assert list.current_page == 2
      assert list.entries == posts |> Enum.take(6) |> Enum.chunk_every(3) |> List.last()
    end

    test "paginate/1 a query with group by" do
      users = create_users_with_posts()
      green = create_tag("green")
      blue = create_tag("blue")

      Enum.each(
        users,
        fn user ->
          Enum.each(
            user.posts,
            fn post ->
              create_post_tag(post, green)
              create_post_tag(post, blue)
            end
          )
        end
      )

      query = from(
        post in Post,
        join: pt in "post_tags",
        on: post.id == pt.post_id,
        join: tag in Tag,
        on: tag.id == pt.tag_id,
        group_by: [post.user_id, tag.slug],
        order_by: [asc: post.user_id, asc: tag.slug],
        select: %{
          user_id: post.user_id,
          count: count(post.id),
          tag: tag.slug
        }
      )

      %Pagination.Ecto.List{} = list = Repo.paginate(query, %{"page_size" => 4})

      [user_one, user_two | _tail] = users

      assert list.entries_count == 40
      assert list.page_size == 4
      assert list.pages_count == 10
      assert list.current_page == 1
      assert list.entries == [
        %{count: 20, user_id: user_one.id, tag: blue.slug},
        %{count: 20, user_id: user_one.id, tag: green.slug},
        %{count: 20, user_id: user_two.id, tag: blue.slug},
        %{count: 20, user_id: user_two.id, tag: green.slug}
      ]
    end
  end
end
