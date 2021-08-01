defmodule Trivial.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create_query = "CREATE TYPE user_type AS ENUM ('user', 'admin')"
    drop_query = "DROP TYPE user_type"
    execute(create_query, drop_query)

    create table(:users) do
      add :email, :string, null: false
      add :sub, :string, null: false
      add :type, :user_type, default: "user"

      timestamps()
    end

    create unique_index(:users, [:sub])
  end
end
