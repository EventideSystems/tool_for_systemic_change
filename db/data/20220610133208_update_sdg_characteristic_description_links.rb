# frozen_string_literal: true

class UpdateSdgCharacteristicDescriptionLinks < ActiveRecord::Migration[6.1]
  def up
    CSV.foreach(filename, headers: false) do |row|
      next if row[0].blank?

      next if row[0].match? /^Goal.*/
      if row[0].match? /^\d*\.\S*\s/
        goal, target = row[0].match(/^(\d*)\.(\S*)\s/)[1..2]

        long_name = row[1]
        link = link_to_wikipedia_page(goal)

        characteristic = find_charactertic(goal, target)
        characteristic.description = description(long_name, link)
        characteristic.save!
      else
        next
      end
    end
  end

  def down
    # NO OP
  end

  private

  def description(long_name, link)
    <<~HTML
      <h1><strong>The full text of Target&nbsp;</strong></h1>
      <div><br></div>
      <h1>#{long_name}</h1>
      <div><br></div>
      <h1><strong>More information</strong>&nbsp;</h1>
      <h1><a href="#{link}" target="_blank">#{link}</a></h1>
    HTML
  end

  def filename
    Rails.root.join("db/data/sdg_targets_cross_walk.csv")
  end

  def find_charactertic(goal, target)
    Characteristic
      .joins(focus_area: :focus_area_group)
      .where('characteristics.name ilike ?', "#{goal}.#{target} %")
      .where('focus_area_groups_focus_areas.name = ?', "SDGs Targets")
      .first
  end

  def link_to_wikipedia_page(goal_number)
    "https://en.wikipedia.org/wiki/Sustainable_Development_Goal_#{goal_number}"
  end
end
