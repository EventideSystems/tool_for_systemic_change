class CreateChecklistItemAtTimeFunctionUsingJsonb < ActiveRecord::Migration[6.0]
  def up
    connection.execute(<<~SQL)
      CREATE OR REPLACE FUNCTION checklist_item_at_time(checklist_item_id INTEGER, at TIMESTAMP) 
      RETURNS BOOLEAN AS $$
      DECLARE checked BOOLEAN;
      BEGIN
        IF at IS NULL THEN 
          SELECT COALESCE(checklist_items.checked, false) INTO STRICT checked
          FROM checklist_items 
          WHERE checklist_items.id = checklist_item_id;
        ELSE
          SELECT  COALESCE(checklist_items.checked, false)
          INTO checked 
          FROM checklist_items 
          WHERE id = checklist_item_id 
          AND updated_at < at;
          
          IF NOT FOUND THEN
            SELECT object->>'checked'
            INTO checked
            FROM versions 
            WHERE item_type = 'ChecklistItem' 
            AND item_id = checklist_item_id
            AND event = 'update'
            AND created_at <= at
            ORDER BY created_at DESC
            LIMIT 1;
          END IF;
      
          IF NOT FOUND THEN
            SELECT false INTO STRICT checked;
          END IF;
        END IF;
        
        RETURN checked;
      END;
      $$ LANGUAGE plpgsql;
      end

    SQL
  end

  def down
    connection.execute(<<~SQL)
      CREATE OR REPLACE FUNCTION checklist_item_at_time(checklist_item_id INTEGER, at TIMESTAMP) 
      RETURNS BOOLEAN AS $$
      DECLARE checked BOOLEAN;
      BEGIN
        IF at IS NULL THEN 
          SELECT COALESCE(checklist_items.checked, false) INTO STRICT checked
          FROM checklist_items 
          WHERE checklist_items.id = checklist_item_id;
        ELSE
          SELECT  COALESCE(checklist_items.checked, false)
          INTO checked 
          FROM checklist_items 
          WHERE id = checklist_item_id 
          AND updated_at < at;
          
          IF NOT FOUND THEN
            SELECT 
              UNNEST(
                REGEXP_MATCHES(object, '.*checked:\s(true|false|\s)', 'g')
              ) = 'true'
            INTO checked
            FROM versions 
            WHERE item_type = 'ChecklistItem' 
            AND item_id = checklist_item_id
            AND event = 'update'
            AND created_at <= at
            ORDER BY created_at DESC
            LIMIT 1;
          END IF;
      
          IF NOT FOUND THEN
            SELECT false INTO STRICT checked;
          END IF;
        END IF;
        
        RETURN checked;
      END;
      $$ LANGUAGE plpgsql;
      end

    SQL
  end
end
