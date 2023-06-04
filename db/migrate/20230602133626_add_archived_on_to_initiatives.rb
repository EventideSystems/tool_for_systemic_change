# frozen_string_literal: true

class AddArchivedOnToInitiatives < ActiveRecord::Migration[7.0]
  def change
    add_column :initiatives, :archived_on, :datetime
  end
end
