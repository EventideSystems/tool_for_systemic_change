# frozen_string_literal: true

class LoadSystemSdgModels < ActiveRecord::Migration[8.0]
  def up
    [
      'sustainable_development_goals_and_targets.yml',
      'sustainable_development_goals_targets_and_indicators.yml'
    ].each do |filename|
      DataModels::Import.call(filename: Rails.root.join('db/data_models', filename))
    end
  end

  def down
    [
      'Sustainable Development Goals and Targets',
      'Sustainable Development Goals, Targets and Indicators'
    ].each do |model_name|
      DataModel.where(public_model: true).find_by(name: model_name)&.really_destroy!
    end
  end
end
