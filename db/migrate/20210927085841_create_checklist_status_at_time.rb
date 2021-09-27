class CreateChecklistStatusAtTime < ActiveRecord::Migration[6.1]
  def up
    connection.execute(<<~SQL)
      CREATE OR REPLACE FUNCTION checklist_item_status_at_time(the_checklist_item_id INTEGER, at TIMESTAMP) 
      RETURNS VARCHAR AS $$
      DECLARE status VARCHAR;
      BEGIN
        IF at IS NULL THEN 
          SELECT COALESCE(checklist_item_comments.status, '') INTO STRICT status
          FROM checklist_item_comments 
          WHERE checklist_item_comments.checklist_item_id = the_checklist_item_id
          ORDER BY created_at DESC LIMIT 1;
        ELSE
          SELECT COALESCE(checklist_item_comments.status, '')
          INTO status 
          FROM checklist_item_comments 
          INNER JOIN checklist_items ON checklist_item_comments.checklist_item_id = checklist_items.id
          WHERE checklist_items.id = the_checklist_item_id 
          AND checklist_item_comments.updated_at < at
          ORDER BY checklist_item_comments.created_at DESC LIMIT 1;
          
          IF NOT FOUND THEN
            SELECT object->>'status'
            INTO status
            FROM versions 
            INNER JOIN checklist_item_comments ON versions.item_id = checklist_item_comments.id
            INNER JOIN checklist_items ON checklist_item_comments.checklist_item_id = checklist_items.id
            WHERE item_type = 'ChecklistItemComment'
            AND versions.item_id  = checklist_item_comments.id
            AND checklist_items.id = the_checklist_item_id
            AND event = 'update'
            AND versions.created_at <= at
            ORDER BY versions.created_at DESC
            LIMIT 1;
          END IF;
      
          IF NOT FOUND THEN
            SELECT '' INTO STRICT status;
          END IF;
        END IF;
        
        RETURN status;
      END;
      $$ LANGUAGE plpgsql;
      end
    SQL
  end

  def down
    connection.execute(<<~SQL)
      DROP FUNCTION checklist_item_status_at_time(checklist_item_id INTEGER, at TIMESTAMP);
    SQL
  end
end
