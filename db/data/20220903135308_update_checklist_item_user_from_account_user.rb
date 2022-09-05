# frozen_string_literal: true

class UpdateChecklistItemUserFromAccountUser < ActiveRecord::Migration[7.0]
  def up
    execute UPDATE_CHECKLIST_ITEM_USER_FROM_ACCOUNT_USER_SQL
  end

  def down
     # NO OP
  end

  UPDATE_CHECKLIST_ITEM_USER_FROM_ACCOUNT_USER_SQL = <<~SQL
    with account_user as (
      select
        checklist_items.id as checklist_item_id,
        accounts_users.user_id as user_id
      from checklist_items
      inner join initiatives on initiatives.id = checklist_items.initiative_id
      inner join scorecards on scorecards.id = initiatives.scorecard_id
      inner join accounts_users on accounts_users.account_id = scorecards.account_id
      where checklist_items.user_id is null
      group by checklist_items.id, accounts_users.user_id
      having count(accounts_users.user_id) = 1
    )
    update checklist_items
    set user_id = account_user.user_id
    from account_user
    where account_user.checklist_item_id = account_user.checklist_item_id
    and checklist_items.user_id is null
  SQL
end
