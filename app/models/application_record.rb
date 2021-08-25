# frozen_string_literal: true
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # def dump_fixture
  #   fixture_file = "#{Rails.root}/test/fixtures/#{self.class.table_name}.yml"
  #   File.open(fixture_file, 'a+') do |f|
  #     f.puts({ "#{self.class.table_name.singularize}_#{id}" => attributes.except('created_at', 'updated_at') }
  #       .to_yaml.sub!(/---\s?/, "\n"))
  #   end
  # end

  class << self
    # Public: Create string-based enum
    def string_enum(definitions)
      definitions.each do |name, values|
        enum name => string_enum_values(values)
      end
    end

    private

    def string_enum_values(values)
      values.to_h { |value| [value.to_sym, value.to_s] }
    end
  end
end
