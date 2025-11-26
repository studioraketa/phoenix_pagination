defmodule Pagination.Test.Admin do
  use Ecto.Schema

  schema "admins" do
    field(:name, :string)
  end
end
