# frozen_string_literal: true

class AddAccountIdToFocusAreaGroups < ActiveRecord::Migration[7.0]
  def change
    add_reference :focus_area_groups, :account, null: true, foreign_key: true
  end
end
