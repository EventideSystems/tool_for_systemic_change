class CreateJoinTableInitiativeOrganisation < ActiveRecord::Migration
  def change
    create_join_table :initiatives, :organisations do |t|
      # t.index [:initiative_id, :organisation_id]
      # t.index [:organisation_id, :initiative_id]
    end
  end
end
