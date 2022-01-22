# frozen_string_literal: true

class ImportBasicSdgTargets < ActiveRecord::Migration[6.1]
  def up
    focus_area_group = fetch_focus_area_group
    current_focus_area = nil

    CSV.foreach(filename, headers: false) do |row|
      if row[0].match? /^Goal.*/
        position = row[0].match(/^Goal\s(\d*).*/)[1].to_i
        current_focus_area = fetch_focus_area(focus_area_group, row[0], position)
      elsif row[0].match? /^\d*\.(\d*).*/
        position = row[0].match(/^\d*\.(\d*).*/)[1].to_i
        create_characteristic(current_focus_area, row[0], position)
      end
    end
  end

  def down
    Characteristic.where(focus_area: FocusArea.where(focus_area_group: FocusAreaGroup.find_by(name: "SDG Targets"))).delete_all
    FocusArea.where(focus_area_group: FocusAreaGroup.find_by(name: "SDG Targets")).delete_all
    FocusAreaGroup.find_by(name: "SDG Targets").delete
  end

  private

  def filename
    Rails.root.join("db/data/basic_sdg_targets.csv")
  end

  def fetch_focus_area_group
    FocusAreaGroup.find_or_create_by(name: "SDG Targets") do |focus_area_group|
      focus_area_group.position = 1
      focus_area_group.scorecard_type = "SustainableDevelopmentGoalAlignmentCard"
    end
  end

  def fetch_focus_area(focus_area_group, name, position)
    FocusArea.find_or_create_by(focus_area_group: focus_area_group, name: name) do |focus_area|
      focus_area.position = position
      focus_area.icon_name = icon_name(name)
    end
  end

  def create_characteristic(focus_area, name, position)
    Characteristic.find_or_create_by(focus_area: focus_area, name: name) do |characteristic|
      characteristic.position = position
    end
  end

  def icon_name(focus_area_name)
    id = "%02d" % focus_area_name.match(/^Goal\s(\d*).*/)[1]
    "E-WEB-Goal-#{id}.png"
  end

end
