defmodule Pagination.Test.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pagination.Test.User

  schema "posts" do
    field(:title, :string)
    field(:content, :string)

    belongs_to :user, User, on_replace: :nilify

    timestamps()
  end
end
