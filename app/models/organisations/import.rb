class Organisations::Import < ApplicationRecord
  
  include ImportUploader[:import]
  
  attr_accessor :processing_errors

  enum status: [ :pending, :processed ]
    
  belongs_to :account
  belongs_to :user
  
  validates :account, presence: true
  validates :user, presence: true 
  
  def process(account)
    name_index        = header_row.index{ |i| i.downcase == 'name'}
    description_index = header_row.index{ |i| i.downcase == 'description'}
    sector_index      = header_row.index{ |i| i.downcase == 'sector'}
    weblink_index     = header_row.index{ |i| i.downcase == 'weblink'}
    
    data_rows.each do |row|
      organisation = Organisation.where("lower(name) = ?", row[name_index].downcase).first
      organisation = Organisation.new(account: account) if organisation.nil?
      
      sector = Sector.find_by(name: row[sector_index])
      
      organisation.name        = row[name_index]
      organisation.description = row[description_index]
      organisation.sector      = sector
      organisation.weblink     = row[weblink_index]
      
      success = organisation.save

      processing_errors << build_processing_errors(organisation) unless success
    end
    
    processing_errors.empty?
  end
  
  def processing_errors
    @processing_errors ||= []
  end
  
  private
  
  def build_processing_errors(organisation)
    full_messages = organisation.errors.full_messages.map do |message|
      if message == "Sector can't be blank"
        "Sector is invalid"
      else
        message
      end  
    end
    
    { record: organisation, full_messages: full_messages }
  end
  
  def rows
    @rows ||= import_data.present? ? load_rows : [] 
  end
  
  def header_row
    rows.first
  end
  
  def data_rows
    rows[1..-1]
  end
  
  def load_rows
    case import.mime_type
    when 'text/csv' 
      import_csv_rows
    when 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' 
      import_xlsx_rows
    end  
  end
  
  def import_csv_rows
    ::CSV.parse(import.read)
  end
  
  def import_xlsx_rows
    xlsx = ::Roo::Spreadsheet.open(import.to_io)
    
    xlsx_rows = []
    xlsx.each_row_streaming do |row|
      xlsx_rows << row.map(&:cell_value)  
    end
    
    xlsx_rows  
  end
  
end
