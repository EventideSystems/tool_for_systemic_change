class CreateImpactCardDataModels < ActiveRecord::Migration[8.0]
  def change
    create_table :data_models do |t|
      t.string :name, null: false
      t.string :short_name
      t.string :description
      t.string :status, default: 'active', null: false
      t.string :color, default: '#0d9488', null: false
      t.references :workspace, null: true, foreign_key: true
      t.boolean :system_model, default: false
      t.datetime :deleted_at
      t.jsonb :metadata, default: {}
      t.timestamps
    end

    add_index :data_models, [:name, :workspace_id], 
      unique: true, 
      where: 'workspace_id IS NOT NULL AND deleted_at IS NULL', name: 'index_data_models_on_name_and_workspace_id'
  end
end
