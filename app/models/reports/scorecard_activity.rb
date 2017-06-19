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
    
    def to_csv
      current_focus_area_group = '' 
      current_focus_area = ''
      
      CSV.generate do |csv|
        
        csv << ['Scorecard', scorecard.name, '', '', '']
        csv << ['Dates range', date_from.strftime('%d/%m/%y'), date_to.strftime('%d/%m/%y'), '', '']
        csv << ['', '', '', '', '']
        
        csv << [
          '',
        	'Total Initiatives beginning of period', 
          'Additions',
          'Removals', 
          'Total Initiatives end of period'
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