class ChangeDataModelSystemModelColumnToPublicModel < ActiveRecord::Migration[8.0]
  def change
    rename_column :data_models, :system_model, :public_model
  end
end
