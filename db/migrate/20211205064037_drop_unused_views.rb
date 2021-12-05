class DropUnusedViews < ActiveRecord::Migration[6.1]
  def change
    connection.execute(<<~SQL)
      DROP VIEW IF EXISTS transition_card_activities CASCADE
    SQL

    connection.execute(<<~SQL)
      DROP VIEW IF EXISTS  checklist_item_checked_view CASCADE
    SQL

    connection.execute(<<~SQL)
      DROP VIEW IF EXISTS  checklist_item_new_comments_view CASCADE
    SQL

    connection.execute(<<~SQL)
      DROP VIEW IF EXISTS  checklist_item_first_comments CASCADE
    SQL

    connection.execute(<<~SQL)
      DROP VIEW IF EXISTS checklist_item_first_comment_view CASCADE
    SQL
  end

  def down
    raise 'Irreversible migration'
  end
end
