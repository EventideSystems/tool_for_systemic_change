class CreateTransitionCardActivities < ActiveRecord::Migration[6.1]
  def up
    # connection.execute(<<~SQL)
    #   CREATE OR REPLACE VIEW transition_card_activities AS        
    #     select
    #       scorecards.id as transition_card_id,
    #       scorecards.name as transition_card_name,
    #       initiatives.id as initiative_id,
    #       initiatives.name as initiative_name,
    #       characteristics.name as characteristic_name,
    #       checklist_item_activities.event,
    #       checklist_item_activities.comment,
    #       checklist_item_activities.occurred_at,
    #       checklist_item_activities.from_status,
    #       checklist_item_activities.to_status 
    #     from checklist_item_activities
    #     inner join checklist_items on checklist_items.id = checklist_item_activities.checklist_item_id
    #     inner join characteristics on characteristics.id = checklist_items.characteristic_id
    #     inner join initiatives on initiatives.id = checklist_items.initiative_id
    #     inner join scorecards on scorecards.id = initiatives.scorecard_id
    # SQL
  end

  def down
    connection.execute(<<~SQL)
      DROP VIEW IF EXISTS transition_card_activities
    SQL
  end
end
