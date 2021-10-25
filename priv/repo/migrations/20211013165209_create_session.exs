defmodule Democrify.Repo.Migrations.CreateSession do
  use Ecto.Migration

  def change do
    create table(:session) do
      add :song_name, :string
      add :username, :string
      add :votes, :integer

      timestamps()
    end
  end
end
