# frozen_string_literal: true

# Load Lewin's Change Management Model example data
class LoadLewinsChangeManagementModelExample < ActiveRecord::Migration[8.0]
  def up
    DataModels::Import.call(filename: Rails.root.join('db/data_models/lewins_change_management_model.yml'))
  end

  def down
    DataModel.find_by(public_model: true, name: "Lewin's Change Management Model")&.really_destroy!
  end
end
