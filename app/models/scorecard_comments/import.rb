class ScorecardComments::Import < Import
  def process(account)
    
    scorecard = nil
    initiatives = {}
    
    focus_area_group_names = FocusAreaGroup.all.pluck(:name)
    focus_area_names = FocusArea.all.pluck(:name)
    characteristic_names = Characteristic.all.pluck(:name)

    data_rows.each.with_index(1) do |raw_row, row_index|
      row = sanitize_row(raw_row)
      
      # Find Scorecard
      if row_index == 1
        scorecard_name = row[1]
        scorecard = find_scorecard_by_name(account, scorecard_name)
        if scorecard.nil?
          processing_errors << build_processing_errors(
            row_data: row, 
            row_index: row_index, 
            error_messages: ["#{Scorecard.model_name.human} is invalid"]
          )
          return false
        end
        next
      end
      
      next if row[0].nil?
      
      # Find Initiatives
      if initiatives.empty? && row[0].downcase == 'name of intiative'
        initiative_names = row[1..-1]
        initiative_names.each_with_index do |initiative_name, index|
          initiative = find_initiative_by_name(scorecard, initiative_name)
          if initiative.nil?
            processing_errors << build_processing_errors(
              row_data: row, 
              row_index: row_index, 
              error_messages: ["#{Initiative.model_name.human} '#{initiative_name}' is invalid"]
            )
            return false
          end
          
          initiatives[index+1] = initiative
        end
      end

      next if row[0].strip.in?(focus_area_group_names) || row[0].strip.in?(focus_area_names) 
      
      if row[0].strip.in?(characteristic_names)
        
        characteristic_name = row[0].strip
         
        row[1..-1].each_with_index do |cell, index|
          comment = cell&.strip
          
          if !comment.blank?
            characteristic = Characteristic.find_by(name: characteristic_name)
            initiative = initiatives[index+1]

            if initiative && characteristic
              checklist_item = initiative.checklist_items.where(characteristic: characteristic).first
              if checklist_item
                checklist_item.comment = comment
                checklist_item.save
              end
            else
              processing_errors << build_processing_errors(
                row_data: row, 
                row_index: row_index, 
                error_messages: ["Unable to match '#{cell}' with a #{Initiative.model_name.human} 'characteristic_name'. Skipping."]
              )
            end
          end
        end
      end
      
    end
    processing_errors.empty?
  end
  
  protected
  
  def data_rows
    rows[0..-1]
  end
  
  private
  
  def find_scorecard_by_name(account, name)
    account.scorecards.where("lower(name) = :name", { name: name.downcase }).first
  end
  
  def find_initiative_by_name(scorecard, name)
    scorecard.initiatives.where("lower(name) = :name", { name: name.downcase }).first
  end
end