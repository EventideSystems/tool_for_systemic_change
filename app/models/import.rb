# frozen_string_literal: true
class Import < ApplicationRecord

  include ImportUploader[:import]
  
  attr_accessor :processing_errors

  enum status: [ :pending, :processed ]
  
  belongs_to :account
  belongs_to :user
  
  validates :account, presence: true
  validates :user, presence: true 
  
  def processing_errors
    @processing_errors ||= []
  end

  def header_row
    rows.first
  end
  
  protected
  
  def sanitize_row(row)
    row.map do |col|
      col.is_a?(String) ? col.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').strip : col
    end
  end
  
  def sanitized_date(col)

    Date.strptime(col, "%d/%m/%y")
  rescue ArgumentError => e
    raise e unless e.message == 'invalid date' 
    begin
      Date.parse(col)
    rescue ArgumentError => e  
      raise e unless e.message == 'invalid date' 
      nil
    end
  end

  def build_processing_errors(row_data:, row_index:, error_messages:)
    full_messages = error_messages.map do |message|
      if message == "Sector can't be blank"
        "Sector is invalid"
      else
        message
      end  
    end
  
    { row_data: row_data, row_index: row_index, error_messages: error_messages }
  end

  def rows
    @rows ||= import_data.present? ? load_rows : [] 
  end

  def data_rows
    rows[1..-1]
  end
  
  def column_index(column_id)
    candidate_column_names = [column_id.to_s.downcase, column_id.to_s.humanize.downcase]
    header_row.index{ |i| i&.downcase.in? candidate_column_names }
  end

  private
  
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
      next if row.last.nil?
      col_count = row.last.coordinate.column
      row_array = Array.new(col_count)
      
      row.each do |cell|
        col_index = cell.coordinate.column - 1
        row_array[col_index] = cell.cell_value
      end
      
      xlsx_rows << row_array
    end
  
    xlsx_rows  
  end
end