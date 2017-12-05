require 'csv'

module Reports
  class ScorecardActivity
    
    attr_accessor :scorecard, :date_from, :date_to
    
    def initialize(scorecard, date_from, date_to)
      @scorecard = scorecard
      @date_from = date_from.beginning_of_day
      @date_to = date_to.end_of_day
    end
    
    def initiative_totals
      @initiative_totals ||= initiatives(date_from, date_to).inject({initial: 0, additions: 0, removals: 0}) do |result, initiative|
        starting_initial = result[:initial] 
        
        result[:initial] += 1 if ChecklistItem.where(initiative: initiative).any? do |item| 
          state_before_range = item.snapshot_at(date_from - 1.second).checked 
          
          state_before_range == true
        end
        
        found_in_initial = starting_initial != result[:initial] 
        
        result[:additions] += 1 if !found_in_initial && ChecklistItem.where(initiative: initiative).any? do |item|
          state_before_range = item.snapshot_at(date_from - 1.second).checked 
          state_within_range = item.snapshot_at(date_to).checked 
          
          state_within_range == true && (state_before_range.nil? || state_before_range == false)
        end
        
        result[:removals] += 1 if found_in_initial && ChecklistItem.where(initiative: initiative).any? do |item|
          state_before_range = item.snapshot_at(date_from - 1.second).checked 
          state_within_range = item.snapshot_at(date_to).checked 
          
          state_within_range == false && state_before_range == true
        end
        
        result[:final] = result[:initial] + result[:additions] - result[:removals]
        result
      end
    end
    
    def results
      @results ||= characteristics.inject([]) do |result, characteristic|
        result << { 
          focus_area_group: characteristic.focus_area.focus_area_group.name,
          focus_area: characteristic.focus_area.name,
          characteristic: characteristic.name,
        }.merge(checklist_item_counts(characteristic, initiatives(date_from, date_to), date_from, date_to))
      end
    end
    
    def to_xlsx
      Axlsx::Package.new do |p|
        p.workbook.styles.fonts.first.name = 'Calibri'
        
        header_1 = p.workbook.styles.add_style :fg_color => "386190", :sz => 16, b: true
        header_2 = p.workbook.styles.add_style :bg_color => "dce6f1", :fg_color => "386190", :sz => 12, b: true
        header_3 = p.workbook.styles.add_style :bg_color => "dce6f1", :fg_color => "386190", :sz => 12, b: false
        blue_normal = p.workbook.styles.add_style :fg_color => "386190", :sz => 12, b: false
        wrap_text = p.workbook.styles.add_style alignment: { horizontal: :general, vertical: :bottom, wrap_text: true }
        date = p.workbook.styles.add_style format_code: "d/m/yy"
        
        p.workbook.add_worksheet(name: 'Report') do |sheet|
          sheet.add_row(["#{Scorecard.model_name.human}"], style: header_1).add_cell(scorecard.name, style: blue_normal)
          sheet.add_row(['Date range'], b: true).tap do |row|
            row.add_cell(date_from, style: date)
            row.add_cell(date_to, style: date)
          end
          sheet.add_row
          sheet.add_row([
            '',
          	'Initiatives beginning of period', 
            'Additions',
            'Removals', 
            'Initiatives end of period'
          ], height: 48, style: wrap_text)
          
          sheet.add_row([
            "Total #{Scorecard.model_name.human} Initiatives", 
            initiative_totals[:initial],
            initiative_totals[:additions],
            initiative_totals[:removals],
            initiative_totals[:final],
          ], style: header_1)
          
          current_focus_area_group = '' 
          current_focus_area = ''
          
          results.each do |result|
            if result[:focus_area_group] != current_focus_area_group
              current_focus_area_group = result[:focus_area_group]
              current_focus_area = ''
              sheet.add_row [result[:focus_area_group], '', '', '', ''], style: header_2
            end
          
            if result[:focus_area] != current_focus_area 
              current_focus_area = result[:focus_area]
              sheet.add_row ["\s\s" + result[:focus_area], '', '', '', ''], style: header_3
            end
          
            sheet.add_row ["\s\s\s\s" + result[:characteristic], result[:initial], result[:additions], result[:removals], result[:final]]
          end
          
          sheet.column_widths 75.5, 10, 10, 10, 10
        end
      end.to_stream
    end
    
    def to_csv
      current_focus_area_group = '' 
      current_focus_area = ''
      
      CSV.generate do |csv|
        
        csv << ["#{Scorecard.model_name.human}", scorecard.name, '', '', '']
        csv << ['Dates range', date_from.strftime('%d/%m/%y'), date_to.strftime('%d/%m/%y'), '', '']
        csv << ['', '', '', '', '']
        
        csv << [
          '',
        	'Initiatives beginning of period', 
          'Additions',
          'Removals', 
          'Initiatives end of period'
        ]
        
        results.each do |result|
          if result[:focus_area_group] != current_focus_area_group
            current_focus_area_group = result[:focus_area_group]
            current_focus_area = ''
            csv << [result[:focus_area_group], '', '', '', '']
          end
          
          if result[:focus_area] != current_focus_area 
            current_focus_area = result[:focus_area]
            csv << ["\t\t" + result[:focus_area], '', '', '', '']
          end
          
          csv << ["\t\t\t\t" + result[:characteristic], result[:initial], result[:additions], result[:removals], result[:final]]
        end
      end
    end

    private
    
    def characteristics
      Characteristic.joins(focus_area: :focus_area_group).order('focus_area_groups.position, focus_areas.position')
    end

    def initiatives(date_from, date_to)
      @initiatives ||= fetch_initiatives(date_from, date_to)
    end
    
    def fetch_initiatives(date_from, date_to)
      params = { date_from: date_from, date_to: date_to }
      
      scorecard.initiatives
        .where('finished_at IS NULL or finished_at >= :date_from', params)
        .where('started_at IS NULL or started_at <= :date_to', params)
    end
    
    def checklist_item_counts(characteristic, initiatives, date_from, date_to)
      checklist_items = ChecklistItem.where(characteristic: characteristic, initiative: initiatives) 
      
      item_counts = checklist_items.inject({initial: 0, additions: 0, removals: 0}) do |counts, item|
        state_before_range = item.snapshot_at(date_from - 1.second).checked 
        state_within_range = item.snapshot_at(date_to).checked 
        
        counts[:initial]   += 1 if state_before_range == true
        counts[:additions] += 1 if state_within_range == true && (state_before_range.nil? || state_before_range == false)
        counts[:removals]  += 1 if state_within_range== false && state_before_range == true

        counts
      end
      
      item_counts[:final] = item_counts[:initial] + item_counts[:additions] - item_counts[:removals]
      item_counts
    end
  end
end