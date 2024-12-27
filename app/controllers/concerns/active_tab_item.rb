# frozen_string_literal: true

# Support for setting the active tab item in a controller
module ActiveTabItem
  extend ActiveSupport::Concern

  def active_tab_item
    self.class.instance_variable_get(:@active_tab_item)
  end

  class_methods do
    def tab_item(name)
      instance_variable_set(:@active_tab_item, name)
    end
  end

  def tab_item(name)
    self.class.tab_item(name)
  end
end
