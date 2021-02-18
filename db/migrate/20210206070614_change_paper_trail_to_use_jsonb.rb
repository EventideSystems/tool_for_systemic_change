class ChangePaperTrailToUseJsonb < ActiveRecord::Migration[6.0]
  def change
    rename_column :versions, :object, :old_object
    add_column :versions, :object, :jsonb
  end
end
