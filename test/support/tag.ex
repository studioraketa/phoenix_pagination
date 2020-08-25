defmodule Pagination.Test.Tag do
  use Ecto.Schema

  schema "tags" do
    field(:slug, :string)
  end
end
