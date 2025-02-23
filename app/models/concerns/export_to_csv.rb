# frozen_string_literal: true

# Basic export to CSV functionality
module ExportToCsv
  extend ActiveSupport::Concern

  included do
    cattr_accessor :_csv_attributes

    def self.csv_attributes(*columns)
      self._csv_attributes = columns
    end

    def self.to_csv
      CSV.generate(headers: true) do |csv|
        csv << _csv_attributes

        # NOTE: Convert to array to preserve order
        all.to_a.each do |user|
          csv << _csv_attributes.map { |attr| user.send(attr) }
        end
      end
    end
  end
end
