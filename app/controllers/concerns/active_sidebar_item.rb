# frozen_string_literal: true

# Support for setting the active navbar item in a controller
module ActiveSidebarItem
  extend ActiveSupport::Concern

  def active_sidebar_item
    self.class.instance_variable_get(:@active_sidebar_item)
  end

  class_methods do
    def sidebar_item(name)
      instance_variable_set(:@active_sidebar_item, name)
    end
  end

  delegate :sidebar_item, to: :class
end
