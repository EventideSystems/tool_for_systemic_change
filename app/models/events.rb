# frozen_string_literal: true

# Events module, mostly for namespacing various database views
module Events
  def self.table_name_prefix
    'events_'
  end
end
