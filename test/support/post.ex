defmodule Pagination.Test.Post do
  use Ecto.Schema

  alias Pagination.Test.User

  schema "posts" do
    field(:title, :string)
    field(:content, :string)
    field(:ord, :integer)

    belongs_to :user, User, on_replace: :nilify

    timestamps()
  end
end
