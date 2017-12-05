class Initiatives::Import < Import
  
  MAX_ORGANIZATION_EXPORT = 15
  
  def process(account)
    name_index             = column_index(:name)
    description_index      = column_index(:description)
    scorecard_name_index   = column_index("#{Scorecard.model_name.human.downcase.gsub(/\s/, '_')}_name".to_sym)
    started_at_index       = column_index(:started_at)
    finished_at_index      = column_index(:finished_at)
    contact_name_index     = column_index(:contact_name)
    contact_email_index    = column_index(:contact_email)
    contact_phone_index    = column_index(:contact_phone)
    contact_website_index  = column_index(:contact_website)
    contact_position_index = column_index(:contact_position)
    
    
    data_rows.each.with_index(1) do |raw_row, row_index|
      
      row = sanitize_row(raw_row)
      
      scorecard = scorecard_name_index.nil? ? nil : find_scorecard_by_name(account, row[scorecard_name_index])
      
      if scorecard.nil?
        processing_errors << build_processing_errors(
          row_data: row, row_index: row_index, error_messages: ["#{Scorecard.model_name.human} is invalid"]
        )
        next  
      end
      
      if name_index.nil? 
        processing_errors << build_processing_errors(
          row_data: row, row_index: row_index, error_messages: ['Initiative name is missing']
        )
        next  
      end
      
      initiative = find_or_build_initiative_by_name(scorecard, row[name_index]) 
      
      unknown_organisation_names = []
      
      1.upto(MAX_ORGANIZATION_EXPORT).each do |org_index|
        organisation_name_index = header_row.index{ |i| i.downcase == "organisation #{org_index} name"}
        organisation_name = row[organisation_name_index]
        
        unless organisation_name.blank?
          organisation = find_organisation_by_name(account, organisation_name)

          if organisation
            initiative.organisations << organisation unless initiative.organisations.include?(organisation)
          else
            unknown_organisation_names << organisation_name
          end
        end
      end

      success = initiative.update(
        {}.tap do |attributes|
          attributes[:name]             = row[name_index] 
          attributes[:description]      = row[description_index]                 if row[description_index].present?
          attributes[:scorecard]        = scorecard
          attributes[:started_at]       = sanitized_date(row[started_at_index])  if row[started_at_index].present?
          attributes[:finished_at]      = sanitized_date(row[finished_at_index]) if row[finished_at_index].present?
          attributes[:contact_name]     = row[contact_name_index]                if row[contact_name_index].present?
          attributes[:contact_email]    = row[contact_email_index]               if row[contact_email_index].present?  
          attributes[:contact_phone]    = row[contact_phone_index]               if row[contact_phone_index].present? 
          attributes[:contact_website]  = row[contact_website_index]             if row[contact_website_index].present?
          attributes[:contact_position] = row[contact_position_index]            if row[contact_position_index].present?
        end
      )
      
      success = success && unknown_organisation_names.empty?

      unless success
        error_messages = initiative.errors.full_messages || []
        error_messages << "Unknown Organisation Names: #{unknown_organisation_names.join(', ')}." unless unknown_organisation_names.empty?
        processing_errors << build_processing_errors(
          row_data: row, row_index: row_index, error_messages: error_messages
        ) 
      end  
    end
    
    processing_errors.empty?
  end
  
  private
  
  def find_scorecard_by_name(account, name)
    account.scorecards.where("lower(name) = :name", { name: name.downcase }).first
  end
  
  def find_organisation_by_name(account, name)
    account.organisations.where("lower(name) = :name", { name: name.downcase }).first
  end
  
  def find_or_build_initiative_by_name(scorecard, name)
    initiative = scorecard.initiatives.where( 
      "lower(name) = :name ", { name: name.downcase }
    ).first
    
    initiative || scorecard.initiatives.build
  end

end
