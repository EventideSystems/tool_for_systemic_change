# frozen_string_literal: true

class ChangeSdgTargetsName < ActiveRecord::Migration[6.1]
  def up
    FocusAreaGroup.find_by(name: 'SDG Targets').update(name: 'SDGs Targets')
  end

  def down
    # NO OP
  end
end
