defmodule Pagination.Test.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :slug, :string, null: false
    end

    create unique_index(:tags, :slug)
  end
end
