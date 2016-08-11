defmodule Rumbl.Repo.Migrations.AddAddressInUser do
  use Ecto.Migration

  def change do
      alter table(:users) do
          add :address, :text          
      end
  end
end
