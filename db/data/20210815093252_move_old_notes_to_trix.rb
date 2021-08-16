# frozen_string_literal: true

class MoveOldNotesToTrix < ActiveRecord::Migration[6.1]
  def up
    Initiative.where.not(old_notes: [nil, '']).each do |initiative|
      initiative.update!(notes: initiative.old_notes)
    end
  end

  def down
    # NO OP
  end
end
