class Initiatives::Import < Import
  
  MAX_ORGANIZATION_EXPORT = 15
  
  def process(account)
    name_index             = header_row.index{ |i| i.downcase == 'name'}
    description_index      = header_row.index{ |i| i.downcase == 'description'}
    scorecard_name_index   = header_row.index{ |i| i.downcase == 'scorecard name'}
    started_at_index       = header_row.index{ |i| i.downcase == 'started at'}
    finished_at_index      = header_row.index{ |i| i.downcase == 'finished at'}
    contact_name_index     = header_row.index{ |i| i.downcase == 'contact name' }
    contact_email_index    = header_row.index{ |i| i.downcase == 'contact email' }
    contact_phone_index    = header_row.index{ |i| i.downcase == 'contact phone' }
    contact_website_index  = header_row.index{ |i| i.downcase == 'contact website' }
    contact_position_index = header_row.index{ |i| i.downcase == 'contact position' }
    
    data_rows.each do |row|
      scorecard = account.scorecards.find_by(name: row[scorecard_name_index])
      
      initiative = scorecard.initiatives.where(
        "lower(name) = :name ", { name: row[name_index].downcase }
      ).first
      initiative = scorecard.initiatives.build if initiative.nil?
      
      organisations = initiative.organisations
      
      1.upto(MAX_ORGANIZATION_EXPORT).each do |org_index|
        organisation_name_index = header_row.index{ |i| i.downcase == "organisation #{org_index} name"}
        organisation_name = row[organisation_name_index]
        
        unless organisation_name.blank?
          organisation = account.organisations.where(
            "lower(name) = :name", { name: organisation_name.downcase }
          ).first
        
          initiative.organisations += [organisation] if organisation
        end
      end

      success = initiative.update(
        {}.tap do |attributes|
          attributes[:name]             = row[name_index] 
          attributes[:description]      = row[description_index]      if row[description_index].present?
          attributes[:scorecard]        = scorecard
          attributes[:started_at]       = row[started_at_index]       if row[started_at_index].present?
          attributes[:finished_at]      = row[finished_at_index]      if row[finished_at_index].present?
          attributes[:contact_name]     = row[contact_name_index]     if row[contact_name_index].present?
          attributes[:contact_email]    = row[contact_email_index]    if row[contact_email_index].present?  
          attributes[:contact_phone]    = row[contact_phone_index]    if row[contact_phone_index].present? 
          attributes[:contact_website]  = row[contact_website_index]  if row[contact_website_index].present?
          attributes[:contact_position] = row[contact_position_index] if row[contact_position_index].present?
        end
      )

      processing_errors << build_processing_errors(organisation, row) unless success
    end
    
    processing_errors.empty?
  end

end
