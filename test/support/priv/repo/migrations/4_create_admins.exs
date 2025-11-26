defmodule Pagination.Test.Migrations.CreateAdmins do
  use Ecto.Migration

  def change do
    create table(:admins) do
      add(:name, :string)
    end
  end
end
