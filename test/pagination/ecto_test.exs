defmodule Pagination.EctoTest do
  use Pagination.TestCase

  alias Pagination.Test.{Repo, Post, User, Tag, PostTag}

  defp create_user do
    %User{name: "John Doe"} |> Repo.insert!()
  end

  defp create_post(user) do
    %Post{user_id: user.id, title: "A Post", content: "Some very insightful stuff here."}
    |> Repo.insert!()
  end

  defp update_post(post, inserted_at) do
    from(p in Post, where: p.id == ^post.id)
    |> Repo.update_all(set: [inserted_at: inserted_at])

    Repo.get!(Post, post.id)
  end

  defp create_tag(slug), do: %Tag{slug: slug} |> Repo.insert!()

  defp create_posts(max_posts \\ 100) do
    user = create_user()
    Enum.map(1..max_posts, fn _num -> create_post(user) end)
  end

  defp create_post_tag(post, tag) do
    %PostTag{post_id: post.id, tag_id: tag.id} |> Repo.insert!()
  end

  defp create_users_with_posts do
    Enum.map(1..20, fn _num ->
      user = create_user()
      posts = Enum.map(1..20, fn _num -> create_post(user) end)
      %User{user | posts: posts}
    end)
  end

  defp encode(val), do: Base.url_encode64(to_string(val))

  describe "cursor pagination" do
    test "paginate/3 raises an error when an Ecto.Query with ordering" do
      query = from(post in Post, order_by: [desc: :id])

      assert_raise RuntimeError, "Cannot cursor-paginate ordered query.", fn ->
        Repo.paginate(query, :cursor)
      end
    end

    test "paginate/3 raises an error when an Ecto.Query with grouping" do
      query = from(
        post in Post,
        join: pt in "post_tags",
        on: post.id == pt.post_id,
        join: tag in Tag,
        on: tag.id == pt.tag_id,
        group_by: [post.user_id, tag.slug],
        select: %{
          user_id: post.user_id,
          count: count(post.id),
          tag: tag.slug
        }
      )

      assert_raise RuntimeError, "Cannot cursor-paginate grouped query.", fn ->
        Repo.paginate(query, :cursor)
      end
    end

    test "paginate/3 paginate a query using the defaults" do
      posts = create_posts()

      %Pagination.Ecto.Cursor.List{} = list = Repo.paginate(Post, :cursor)

      entries = posts |> Enum.reverse |> Enum.take(5)

      assert list.entries == entries
      assert list.cursor == encode(List.last(entries).id)
      assert list.page_size == 5
    end

    test "paginate/3 paginate a query using the defaults for non existent entries" do
      %Pagination.Ecto.Cursor.List{} = list = Repo.paginate(Post, :cursor)

      assert list.entries == []
      assert list.cursor == nil
      assert list.page_size == 5
    end

    test "paginate/3 paginate a query using input parameters" do
      posts = create_posts()

      %Pagination.Ecto.Cursor.List{} = list = Repo.paginate(
        Post,
        :cursor,
        %{
          field: :id,
          direction: :asc,
          page_size: 20,
        }
      )

      entries = Enum.take(posts, 20)

      assert list.entries == entries
      assert list.cursor == encode(List.last(entries).id)
      assert list.page_size == 20
    end

    test "paginate/3 paginate a query with a cursor when direction is asc" do
      posts = create_posts()

      post20 = posts |> Enum.take(20) |> List.last

      %Pagination.Ecto.Cursor.List{} = list = Repo.paginate(
        Post,
        :cursor,
        %{
          field: :id,
          direction: :asc,
          page_size: 20,
          cursor: encode(post20.id)
        }
      )

      entries = posts |> Enum.take(40) |> Enum.chunk_every(20) |> List.last()

      assert list.entries == entries
      assert list.cursor == encode(List.last(entries).id)
      assert list.page_size == 20
    end

    test "paginate/3 paginate when fetching the last page the cursor is nil" do
      posts = create_posts(20)

      post10 = posts |> Enum.take(10) |> List.last

      %Pagination.Ecto.Cursor.List{} = list = Repo.paginate(
        Post,
        :cursor,
        %{
          field: :id,
          direction: :asc,
          page_size: 20,
          cursor: encode(post10.id)
        }
      )

      entries = posts |> Enum.chunk_every(10) |> List.last()

      assert list.entries == entries
      assert list.cursor == nil
      assert list.page_size == 20
    end

    test "paginate/3 paginate a query with a cursor for given field and direction" do
      posts = create_posts()

      posts = Enum.map(posts, fn post ->
        update_post(post, NaiveDateTime.add(post.inserted_at, post.id))
      end)

      post20 = posts |> Enum.take(20) |> List.last

      %Pagination.Ecto.Cursor.List{} = list = Repo.paginate(
        Post,
        :cursor,
        %{
          field: :inserted_at,
          direction: :asc,
          page_size: 20,
          cursor: encode(post20.inserted_at)
        }
      )

      entries = posts |> Enum.take(40) |> Enum.chunk_every(20) |> List.last()

      assert list.entries == entries
      assert list.cursor == encode(List.last(entries).inserted_at)
      assert list.page_size == 20
    end

    test "paginate/3 paginate a query with a cursor when direction is desc" do
      posts = create_posts()

      post20 = posts |> Enum.reverse() |> Enum.take(20) |> List.last

      %Pagination.Ecto.Cursor.List{} = list = Repo.paginate(
        Post,
        :cursor,
        %{
          field: :id,
          direction: :desc,
          page_size: 20,
          cursor: encode(post20.id)
        }
      )

      entries = posts |> Enum.reverse() |> Enum.take(40) |> Enum.chunk_every(20) |> List.last()

      assert list.entries == entries
      assert list.cursor == encode(List.last(entries).id)
      assert list.page_size == 20
    end

    test "paginate/3 paginates with preloads" do
      users = create_users_with_posts()

      %Pagination.Ecto.Cursor.List{} = list =
        from(user in User, where: ilike(user.name, "%John%"))
        |> preload(:posts)
        |> Repo.paginate(
          :cursor,
          %{
            "field" => :id,
            "direction" => :asc,
            "page_size" => 3,
          }
        )

      entries = Enum.take(users, 3)

      assert list.page_size == 3
      assert list.entries == entries
      assert list.cursor == encode(List.last(entries).id)
      refute List.first(list.entries).posts == []
    end

    test "paginate/3 works with a query containing distinct" do
      posts = create_posts(10)

      %Pagination.Ecto.Cursor.List{} = list =
        Post
        |> distinct(true)
        |> Repo.paginate(
          :cursor,
          %{
            "field" => :id,
            "direction" => :asc,
            "page_size" => 3
          }
        )

      entries = Enum.take(posts, 3)

      assert list.page_size == 3
      assert list.entries == entries
      assert list.cursor == encode(List.last(entries).id)
    end

    test "paginate/3 works with a join query containing distinct" do
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

      %Pagination.Ecto.Cursor.List{} = list = Repo.paginate(
        query,
        :cursor,
        %{
          "field" => :id,
          "direction" => :asc,
          "page_size" => 3
        }
      )

      entries = Enum.take(posts, 3)

      assert list.page_size == 3
      assert list.entries == entries
      assert list.cursor == encode(List.last(entries).id)
    end
  end

  describe "pagination" do
    test "paginate/3 paginate a query using the defaults" do
      posts = create_posts()

      %Pagination.Ecto.Offset.List{} = list = Repo.paginate(Post, :offset)

      assert list.entries_count == 100
      assert list.page_size == 5
      assert list.pages_count == 20
      assert list.current_page == 1
      assert list.entries == Enum.take(posts, 5)
    end

    test "paginate/3 generate list result for non existent entries" do
      %Pagination.Ecto.Offset.List{} = list = Repo.paginate(Post, :offset)

      assert list.entries_count == 0
      assert list.page_size == 5
      assert list.pages_count == 0
      assert list.current_page == 1
      assert list.entries == []
    end

    test "paginate/3 paginate a query using the input page and page_size" do
      posts = create_posts()

      %Pagination.Ecto.Offset.List{} = list = Repo.paginate(Post, :offset, %{"page" => 2, "page_size" => 3})

      assert list.entries_count == 100
      assert list.page_size == 3
      assert list.pages_count == 34
      assert list.current_page == 2
      assert list.entries == posts |> Enum.take(6) |> Enum.chunk_every(3) |> List.last()
    end

    test "paginate/3 paginates with preloads" do
      users = create_users_with_posts()

      %Pagination.Ecto.Offset.List{} = list =
        from(user in User, where: ilike(user.name, "%John%"))
        |> preload(:posts)
        |> Repo.paginate(:offset, %{"page" => 2, "page_size" => 3})

      assert list.entries_count == 20
      assert list.page_size == 3
      assert list.pages_count == 7
      assert list.current_page == 2
      assert list.entries == users |> Enum.take(6) |> Enum.chunk_every(3) |> List.last()
      refute List.first(list.entries).posts == []
    end

    test "paginate/3 works with a query containing distinct" do
      posts = create_posts()

      %Pagination.Ecto.Offset.List{} = list =
        Post
        |> order_by(asc: :id)
        |> distinct(true)
        |> Repo.paginate(:offset, %{"page" => 2, "page_size" => 3})

      assert list.entries_count == 100
      assert list.page_size == 3
      assert list.pages_count == 34
      assert list.current_page == 2
      assert list.entries == posts |> Enum.take(6) |> Enum.chunk_every(3) |> List.last()
    end

    test "paginate/3 works with a join query containing distinct" do
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

      %Pagination.Ecto.Offset.List{} = list = Repo.paginate(query, :offset, %{"page" => 2, "page_size" => 3})

      assert list.entries_count == 100
      assert list.page_size == 3
      assert list.pages_count == 34
      assert list.current_page == 2
      assert list.entries == posts |> Enum.take(6) |> Enum.chunk_every(3) |> List.last()
    end

    test "paginate/3 a query with group by" do
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

      %Pagination.Ecto.Offset.List{} = list = Repo.paginate(query, :offset, %{"page_size" => 4})

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
