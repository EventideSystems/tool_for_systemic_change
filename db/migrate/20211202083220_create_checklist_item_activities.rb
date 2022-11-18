class CreateChecklistItemActivities < ActiveRecord::Migration[6.1]
  def up
    connection.execute(<<~SQL)
      CREATE OR REPLACE VIEW checklist_item_activities AS
        select * from checklist_item_first_comment_view
        union
        select * from checklist_item_updated_comments_view
        union
        select * from checklist_item_new_comments_view
        union
        select * from checklist_item_checked_view
    SQL
  end

  def down
    connection.execute(<<~SQL)
      DROP VIEW IF EXISTS checklist_item_activities
    SQL
  end
end
