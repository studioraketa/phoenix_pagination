defmodule Pagination.Test.Post do
  use Ecto.Schema

  schema "posts" do
    field(:title, :string)
    field(:content, :string)

    timestamps()
  end
end
