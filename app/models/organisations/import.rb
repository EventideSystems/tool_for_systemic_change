class Organisations::Import < Import
  
  def process(account)
    name_index        = header_row.index{ |i| i.downcase == 'name'}
    description_index = header_row.index{ |i| i.downcase == 'description'}
    sector_index      = header_row.index{ |i| i.downcase == 'sector'}
    weblink_index     = header_row.index{ |i| i.downcase == 'weblink'}
    
    data_rows.each do |row|
      organisation = Organisation.where(
        "lower(name) = :name AND account_id = :account_id", 
        { name: row[name_index].downcase, account_id: account.id }
      ).first
      organisation = Organisation.new(account: account) if organisation.nil?
      
      sector = Sector.find_by(name: row[sector_index])
      
      organisation.name        = row[name_index]
      organisation.description = row[description_index]
      organisation.sector      = sector
      organisation.weblink     = row[weblink_index]
      
      success = organisation.save!

      processing_errors << build_processing_errors(organisation) unless success
    end
    
    processing_errors.empty?
  end
  
end