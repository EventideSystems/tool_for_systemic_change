class AddTimestampToUsers < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :created_at, :datetime
    add_column :users, :updated_at, :datetime
    
    execute 'UPDATE users set created_at=current_timestamp, updated_at=current_timestamp'
    
    change_column_null :users, :created_at, true
    change_column_null :users, :updated_at, true
  end
  
  def down
    remove_column :users, :created_at, :datetime
    remove_column :users, :updated_at, :datetime
  end
end