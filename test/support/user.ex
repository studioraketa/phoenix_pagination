defmodule Pagination.Test.User do
  use Ecto.Schema

  alias Pagination.Test.Post

  schema "users" do
    field(:name, :string)

    has_many :posts, Post
  end
end
