class Organisations::Import < Import
  
  def process(account)
    name_index        = header_row.index{ |i| i.downcase == 'name'}
    description_index = header_row.index{ |i| i.downcase == 'description'}
    sector_index      = header_row.index{ |i| i.downcase == 'sector'}
    weblink_index     = header_row.index{ |i| i.downcase == 'weblink'}
    
    data_rows.each.with_index(1) do |row, row_index|
      organisation = find_or_build_organisation_by_name(account, row[name_index])
      sector = sector_index.nil? ? nil : find_sector_by_name(row[sector_index])
      
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