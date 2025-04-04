# frozen_string_literal: true

class LoadSystemSdgModels < ActiveRecord::Migration[8.0]
  def up
    SdgDataModelLoader.new.call
  end

  def down
    [SdgDataModelLoader::TWO_TIER_SDG_DATA_MODEL_NAME, SdgDataModelLoader::THREE_TIER_SDG_DATA_MODEL_NAME].each do |model_name|
      ImpactCardDataModel.where(system_model: true).find_by(name: model_name)&.really_destroy!
    end
  end
end
