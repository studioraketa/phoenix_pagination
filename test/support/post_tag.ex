defmodule Pagination.Test.PostTag do
  use Ecto.Schema

  alias Pagination.Test.{Post, Tag}

  schema "post_tags" do
    belongs_to :tag, Tag
    belongs_to :post, Post
  end
end
