class AddStartedAtFinishedAtToInitiatives < ActiveRecord::Migration
  def change
    add_column :initiatives, :started_at, :date
    add_column :initiatives, :finished_at, :date
    add_column :initiatives, :dates_confirmed, :boolean
  end
end
