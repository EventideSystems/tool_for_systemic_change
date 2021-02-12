class CreateUpdatedComments < ActiveRecord::Migration[6.0]
  def up
    connection.execute(<<~SQL)
      INSERT INTO checklist_item_comments (
        checklist_item_id, comment, created_at, updated_at
      )
      SELECT 
        checklist_items.id, 
        checklist_items.comment, 
        checklist_items.updated_at, 
        checklist_items.updated_at 
      FROM checklist_items
      INNER JOIN checklist_item_first_comments 
        ON checklist_item_first_comments.checklist_item_id = checklist_items.id
        AND checklist_item_first_comments.first_comment <> checklist_items.comment
    SQL
  end

  def down; end
end
