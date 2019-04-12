class Organisations::Import < Import
  
  def process(account)
    name_index        = column_index(:name)
    description_index = column_index(:description)
    sector_index      = column_index(:sector)
    weblink_index     = column_index(:weblink)

    if name_index.nil?
      processing_errors << build_processing_errors(
        row_data: data_rows.first, row_index: 0, error_messages: ["Import file is mising 'name' header on first line"]
      )
      return false
    end
    
    data_rows.each.with_index(1) do |raw_row, row_index|
      
      row = sanitize_row(raw_row)
      
      if row[name_index].blank?
        processing_errors << build_processing_errors(
          row_data: row, row_index: row_index, error_messages: ['Row is missing name value']
        )
        next  
      end
      
      organisation = find_or_build_organisation_by_name(account, row[name_index])
      sector = sector_index.nil? ? nil : find_sector_by_name(row[sector_index])
      
      if sector.nil?
        processing_errors << build_processing_errors(
          row_data: row, row_index: row_index, error_messages: ['Sector is invalid']
        )
        next  
      end
      
      success = organisation.update(
        {}.tap do |attributes|
          attributes[:name]        = row[name_index] 
          attributes[:description] = row[description_index] if description_index && row[description_index].present?
          attributes[:sector]      = sector
          attributes[:weblink]     = row[weblink_index] if weblink_index && row[weblink_index].present?
        end
      )

      processing_errors << build_processing_errors(
        row_data: row, row_index: row_index, error_messages: organisation.errors.full_messages
      ) unless success
    end
    
    processing_errors.empty?
  end
  
  private
  
  def find_sector_by_name(name)
    return nil if name.nil?
    Sector.where("lower(name) = :name", { name: name.downcase } ).first
  end
  
  def find_or_build_organisation_by_name(account, name)
    organisation = account.organisations.where(
      "lower(name) = :name", { name: name.downcase }
    ).first
    
    organisation || account.organisations.build
  end
  
end