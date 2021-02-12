class CreateFirstComments < ActiveRecord::Migration[6.0]
  def up
    connection.execute(<<~SQL)
      INSERT INTO checklist_item_comments (
        checklist_item_id, comment, created_at, updated_at
      )
      SELECT checklist_item_id, first_comment, first_comment_at, first_comment_at 
      FROM checklist_item_first_comments
    SQL
  end

  def down
    connection.execute(<<~SQL)
      DELETE FROM checklist_item_comments
    SQL
  end
end
