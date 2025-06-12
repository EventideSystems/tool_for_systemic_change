class DeprecateScorecardsType < ActiveRecord::Migration[8.0]
  def change
    rename_column :scorecards, :type, :deprecated_type
  end
end
