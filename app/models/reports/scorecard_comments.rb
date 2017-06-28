require 'csv'

module Reports
  class ScorecardComments
    
    attr_reader :scorecard, :date
    
    def initialize(scorecard, date)
      @scorecard = scorecard
      @date = date
    end
    
    def results
      characteristics.inject([]) do |result, characteristic|
        result << { 
          focus_area_group: characteristic.focus_area.focus_area_group.name,
          focus_area: characteristic.focus_area.name,
          characteristic: characteristic.name,
        }.merge(comment_counts(characteristic, initiatives, date))
         .merge(initiative_comments(characteristic, initiatives, date))
      end
    end
    
    def initiatives
      @initiatives ||= fetch_initiatives(date)
    end
    
    def to_xlsx
      Axlsx::Package.new do |p|
        p.workbook.styles.fonts.first.name = 'Calibri'
        
        header_1 = p.workbook.styles.add_style :fg_color => "386190", :sz => 16, b: true
        header_2 = p.workbook.styles.add_style :bg_color => "dce6f1", :fg_color => "386190", :sz => 12, b: true
        header_3 = p.workbook.styles.add_style :bg_color => "dce6f1", :fg_color => "386190", :sz => 12, b: false
        blue_normal = p.workbook.styles.add_style :fg_color => "386190", :sz => 12, b: false
        wrap_text = p.workbook.styles.add_style alignment: { horizontal: :general, vertical: :bottom, wrap_text: true }
        date_format = p.workbook.styles.add_style format_code: "d/m/yy"
        
        p.workbook.add_worksheet do |sheet|
          sheet.add_row(['Scorecard'], style: header_1).add_cell(scorecard.name, style: blue_normal)
          sheet.add_row(['Date'], b: true).tap do |row|
            row.add_cell(date, style: date_format)
          end
          
          sheet.add_row
          
          sheet.add_row [
            '',
          	'Total initiatives', 
            'Total comments'
            ] + initiatives.map.with_index {|_, index| "Initiative #{index+1}" }
          
          current_focus_area_group = '' 
          current_focus_area = ''
            
          results.each do |result|
            if result[:focus_area_group] != current_focus_area_group
              current_focus_area_group = result[:focus_area_group]
              current_focus_area = ''
              sheet.add_row [result[:focus_area_group]] + Array.new(initiatives.count + 2, ''), style: header_2
            end
      
            if result[:focus_area] != current_focus_area 
              current_focus_area = result[:focus_area]
              sheet.add_row  ["\s\s" + result[:focus_area]] + Array.new(initiatives.count + 2, ''), style: header_3
            end

            sheet.add_row [
              "\s\s\s\s" + result[:characteristic], 
              result[:initiatives_count], 
              result[:comment_counts]                          
            ] + initiatives.map.with_index {|_, index| result["initiative_#{index+1}".to_sym] }
          end
          sheet.column_widths 75.5, 10, 10
        end
      end.to_stream
    end
    
    def to_csv
      current_focus_area_group = '' 
      current_focus_area = ''
      
      CSV.generate do |csv|
        
        csv << ['Scorecard', scorecard.name] + Array.new(initiatives.count + 1, '')
        csv << ['Date', date.strftime('%d/%m/%y')] + Array.new(initiatives.count + 1, '')
        csv << Array.new(initiatives.count + 3, '')
        
        csv << [
          '',
        	'Total initiatives', 
          'Total comments'
          ] + initiatives.map.with_index {|_, index| "Initiative #{index+1}" }
          
        results.each do |result|
          if result[:focus_area_group] != current_focus_area_group
            current_focus_area_group = result[:focus_area_group]
            current_focus_area = ''
            csv << [result[:focus_area_group]] + Array.new(initiatives.count + 2, '')
          end
        
          if result[:focus_area] != current_focus_area 
            current_focus_area = result[:focus_area]
            csv << ["\t\t" + result[:focus_area]] + Array.new(initiatives.count + 2, '')
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
    
    def comment_counts(characteristic, initiatives, date)
      
      checklist_items = ChecklistItem.where(characteristic: characteristic, initiative: initiatives) 
      
      counts = checklist_items.inject({initiatives_count: 0, comment_counts: 0}) do |count, item|
        comment_counts = 0  
        comment_counts = 1 if (item.updated_at <= date && !item.comment.blank?)
        comment_counts += item.versions.inject(0) do |version_count, version|
          version_count += 1 if !version.reify.nil? && version.reify.updated_at <= date && !version.reify.comment.blank?
          version_count
        end 
        
        count[:comment_counts] += comment_counts
        count[:initiatives_count] += 1 if comment_counts > 0
        
        count
      end
      counts
    end
    
    def initiative_comments(characteristic, initiatives, date)
      comments = {}
      initiatives.each_with_index do |initiative, index|
        
        checklist_item = ChecklistItem.find_by(characteristic: characteristic, initiative: initiative) 
        
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