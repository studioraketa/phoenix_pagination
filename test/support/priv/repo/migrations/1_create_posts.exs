defmodule Pagination.Test.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :content, :string
      add(:user_id, references(:users, on_delete: :delete_all), null: false)

      timestamps()
    end
  end
end
