class AddStartedAndFinishedAtIndexesToInitiatives < ActiveRecord::Migration[5.0]
  def change
    add_index :initiatives, :started_at
    add_index :initiatives, :finished_at
  end
end
