require 'csv'

module Reports
  class ScorecardComments
    
    attr_reader :scorecard, :date
    
    def initialize(scorecard, date)
      @scorecard = scorecard
      @date = date
    end
    
    def results
      @results ||= generate_results.inject([]) do |result, record|        
        result << { 
          focus_area_group: record['focus_area_group_name'],
          focus_area: record['focus_area_name'],
          characteristic: record['characteristic_name'],
          characteristic_id: record['characteristic_id'],
          comment_counts: record['comments_count'],
          initiatives_count: record['initiatives_count']
        }
      end
    end
    
    def comments
      @comments ||= generate_comments
    end
    
    def initiatives
      @initiatives ||= fetch_initiatives(date)
    end
    
    def to_xlsx
      padding_plus_2 = Array.new(initiatives.count + 2, '')
      
      Axlsx::Package.new do |p|
        p.workbook.styles.fonts.first.name = 'Calibri'
        
        header_1 = p.workbook.styles.add_style :fg_color => "386190", :sz => 16, b: true
        header_2 = p.workbook.styles.add_style :bg_color => "dce6f1", :fg_color => "386190", :sz => 12, b: true
        header_3 = p.workbook.styles.add_style :bg_color => "dce6f1", :fg_color => "386190", :sz => 12, b: false
        blue_normal = p.workbook.styles.add_style :fg_color => "386190", :sz => 12, b: false
        wrap_text = p.workbook.styles.add_style alignment: { horizontal: :general, vertical: :bottom, wrap_text: true }
        date_format = p.workbook.styles.add_style format_code: "d/m/yy"
        
        p.workbook.add_worksheet(name: 'Report') do |sheet|
          sheet.add_row(["#{Scorecard.model_name.human}"], style: header_1).add_cell(scorecard.name, style: blue_normal)
          sheet.add_row(['Date'], b: true).tap do |row|
            row.add_cell(date, style: date_format)
          end
          
          sheet.add_row
          
          sheet.add_row [
            '',
          	'Total initiatives', 
            'Total comments'
            ] + initiatives.map(&:name)
          
          current_focus_area_group = '' 
          current_focus_area = ''
            
          results.each do |result|
            if result[:focus_area_group] != current_focus_area_group
              current_focus_area_group = result[:focus_area_group]
              current_focus_area = ''
              sheet.add_row [result[:focus_area_group]] + padding_plus_2, style: header_2
            end
      
            if result[:focus_area] != current_focus_area 
              current_focus_area = result[:focus_area]
              sheet.add_row  ["\s\s" + result[:focus_area]] + padding_plus_2, style: header_3
            end
 
            characteristic_comments = comments.detect { |a| a['characteristic_id'] == result[:characteristic_id] } 
           
            initiative_comments = initiatives.map do |initiative| 

              if characteristic_comments
                
                sorted_comments = JSON.parse(characteristic_comments['comment'])
                  .sort_by { |comment| comment['date'] }
                  .reverse
                
                sorted_comments.each_with_object([]) do |characteristic_comment, memo|
                  if characteristic_comment['initiative_id'] == initiative.id
                    memo << "[#{characteristic_comment['date']}] #{characteristic_comment['comment']}"
                  end
                end.join('; ')
              else
                nil
              end  
              
            end
            
            sheet.add_row [
              "\s\s\s\s" + result[:characteristic], 
              result[:initiatives_count], 
              result[:comment_counts]
            ] + initiative_comments
          end
          sheet.column_widths 75.5, 10, 10
        end
      end.to_stream
    end
    
    def to_csv
      current_focus_area_group = '' 
      current_focus_area = ''

      padding_plus_1 = Array.new(initiatives.count + 1, '')
      padding_plus_2 = Array.new(initiatives.count + 2, '')
      
      CSV.generate do |csv|
        
        csv << ["#{Scorecard.model_name.human}", scorecard.name] + padding_plus_1
        csv << ['Date', date.strftime('%d/%m/%y')] + padding_plus_1
        csv << Array.new(initiatives.count + 3, '')
        
        csv << [
          '',
        	'Total initiatives', 
          'Total comments'
          ] + initiatives.map(&:name)
          
        results.each do |result|
          if result[:focus_area_group] != current_focus_area_group
            current_focus_area_group = result[:focus_area_group]
            current_focus_area = ''
            csv << [result[:focus_area_group]] + padding_plus_2
          end
        
          if result[:focus_area] != current_focus_area 
            current_focus_area = result[:focus_area]
            csv << ["\t\t" + result[:focus_area]] + padding_plus_2
          end

          csv << [
            "\t\t\t\t" + result[:characteristic], 
            result[:initiatives_count], 
            result[:comment_counts]                          
          ] + initiatives.map.with_index {|_, index| result["initiative_#{index+1}".to_sym] }
        end
      end
    end
    
    private
    
    def generate_results
      sql = <<~SQL
        SELECT
          focus_area_groups.name AS focus_area_group_name,
          focus_areas.name AS focus_area_name,
          characteristics.name AS characteristic_name,
          characteristics.id AS characteristic_id,
  
          ( SELECT COUNT(DISTINCT(initiative_checklist_items.initiative_id)) FROM 
            ( 
              SELECT initiatives.id AS initiative_id FROM initiatives
              INNER JOIN checklist_items ON checklist_items.initiative_id = initiatives.id 
                AND checklist_items.characteristic_id = characteristics.id
                AND TRIM(checklist_items.comment)  <> ''
                AND checklist_items.updated_at <= '#{date.to_s}'
              WHERE initiatives.scorecard_id = #{scorecard.id}
    
              UNION
      
              SELECT initiatives.id AS initiative_id FROM initiatives
              INNER JOIN checklist_items ON checklist_items.initiative_id = initiatives.id 
                AND checklist_items.characteristic_id = characteristics.id
              INNER JOIN versions ON versions.item_id = checklist_items.id 
                AND versions.item_type = 'ChecklistItem'   
                AND versions.event = 'update'
                AND TRIM(substring(versions.object from 'comment\:\s(.*)\ncharacteristic_id')) <> ''
                AND versions.created_at <= '#{date.to_s}'
              WHERE initiatives.scorecard_id = #{scorecard.id}
            ) as initiative_checklist_items
          ) AS initiatives_count,
  
          (
            ( SELECT COUNT(id) FROM checklist_items
              WHERE checklist_items.characteristic_id = characteristics.id
              AND checklist_items.initiative_id IN (SELECT id FROM initiatives WHERE initiatives.scorecard_id = #{scorecard.id})
              AND TRIM(checklist_items.comment)  <> ''
              AND checklist_items.updated_at <= '#{date.to_s}'
            )

            +
  
            ( SELECT COUNT(DISTINCT substring(versions.object from 'comment\:\s(.*)\ncharacteristic_id')) 
              FROM versions
              WHERE versions.item_type = 'ChecklistItem'
              AND versions.item_id IN (
                SELECT checklist_items.id FROM checklist_items 
                INNER JOIN initiatives ON initiatives.id = checklist_items.initiative_id
                WHERE checklist_items.characteristic_id = characteristics.id 
                AND initiatives.scorecard_id = #{scorecard.id}
              )
              AND versions.event = 'update'
              AND TRIM(substring(versions.object from 'comment\:\s(.*)\ncharacteristic_id')) <> ''
              AND TRIM(substring(versions.object from 'comment\:\s(.*)\ncharacteristic_id')) <> ( 
                SELECT comment FROM checklist_items
                WHERE checklist_items.id = versions.item_id
              )
              AND versions.created_at <= '#{date.to_s}'
            ) 
          ) AS comments_count
          
          
  
        FROM characteristics
        INNER JOIN focus_areas ON focus_areas.id = characteristics.focus_area_id AND focus_areas.deleted_at IS NULL
        INNER JOIN focus_area_groups ON focus_area_groups.id = focus_areas.focus_area_group_id AND focus_area_groups.deleted_at IS NULL
        WHERE characteristics.deleted_at IS NULL
        ORDER BY focus_area_groups.position ASC, focus_areas.position ASC, characteristics.position ASC;
      SQL
      
      ActiveRecord::Base.connection.execute(sql)
    end
    
    def generate_comments
      sql = <<~SQL
        SELECT
          characteristic_id,
          json_strip_nulls(
            json_agg(
              json_build_object(
                'initiative_id', initiative_id, 
                'comment', comment_text,
                'date', comment_date::timestamp::date
              )
            )
          ) AS comment
        FROM (
          SELECT
            characteristics.id AS characteristic_id, 
            initiatives.id AS initiative_id, 
            checklist_items.comment as comment_text, 
            checklist_items.updated_at as comment_date
          FROM checklist_items
          INNER JOIN initiatives ON initiatives.id = checklist_items.initiative_id
          INNER JOIN characteristics ON characteristics.id = checklist_items.characteristic_id
          AND checklist_items.updated_at <= '#{date.to_s}'
          AND TRIM(checklist_items.comment) <> ''
          AND initiatives.scorecard_id = #{scorecard.id}
          AND checklist_items.characteristic_id = characteristics.id
  
          UNION
  
          SELECT
            characteristics.id,
            initiatives.id AS initiative_id,
            TRIM(substring(versions.object from 'comment\:\s(.*)\ncharacteristic_id')) as comment_text, 
            versions.created_at as comment_date 
          FROM checklist_items
          INNER JOIN initiatives ON initiatives.id = checklist_items.initiative_id
          INNER JOIN characteristics ON characteristics.id = checklist_items.characteristic_id
          INNER JOIN versions ON versions.item_id = checklist_items.id 
            AND versions.item_type = 'ChecklistItem'   
            AND versions.event = 'update'
            AND TRIM(substring(versions.object from 'comment\:\s(.*)\ncharacteristic_id')) <> ''
            AND versions.created_at <= '#{date.to_s}'
          LEFT JOIN versions previous_versions ON previous_versions.item_id = checklist_items.id 
            AND previous_versions.item_type = 'ChecklistItem'   
            AND previous_versions.event = 'update'
            AND TRIM(substring(previous_versions.object from 'comment\:\s(.*)\ncharacteristic_id')) <> ''
            AND previous_versions.created_at <= '#{date.to_s}' 
            AND previous_versions.created_at < versions.created_at
          WHERE 
            initiatives.scorecard_id = #{scorecard.id}
            AND (
              substring(previous_versions.object from 'comment\:\s(.*)\ncharacteristic_id') <> 
              substring(versions.object from 'comment\:\s(.*)\ncharacteristic_id')
              OR
              previous_versions.object IS NULL
            )
        ) checklist_comments
        GROUP BY characteristic_id
        ORDER BY characteristic_id;
      SQL
      
      ActiveRecord::Base.connection.execute(sql)
    end

    def initiative_comments(characteristic, initiatives, date)
      comments = {}
      initiatives.each_with_index do |initiative, index|

        checklist_item = ChecklistItem
          .includes(:versions)
          .find_by(characteristic: characteristic, initiative: initiative)

        checklist_item_comments = []
        checklist_item_comments << "[#{checklist_item.updated_at.strftime('%Y-%m-%d')}] #{checklist_item.comment}" if (checklist_item.updated_at <= date && !checklist_item.comment.blank?)
        checklist_item_comments += checklist_item.versions.inject([]) do |version_comments, version|
          if !version.reify.nil? && version.reify.updated_at <= date && !version.reify.comment.blank?
            version_comments << "[#{version.reify.updated_at.strftime('%Y-%m-%d')}] #{version.reify.comment}"
          end
          version_comments
        end

        comments["initiative_#{index+1}".to_sym] = checklist_item_comments.compact.reverse.join(';')
      end

      comments
    end

    # SMELL Duplicate from ScorecardActivity
    def characteristics
      Characteristic.joins(focus_area: :focus_area_group).order('focus_area_groups.position, focus_areas.position')
    end
    
    def fetch_initiatives(date)
      params = { date: date }
      
      scorecard.initiatives
        .where('started_at <= :date OR started_at IS NULL', params)
        .where('finished_at >= :date OR finished_at IS NULL', params)
    end
  end
end