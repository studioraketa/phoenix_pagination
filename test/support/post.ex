defmodule Pagination.Test.Post do
  use Ecto.Schema

  alias Pagination.Test.User

  schema "posts" do
    field(:title, :string)
    field(:content, :string)

    belongs_to :user, User, on_replace: :nilify
  end
end
