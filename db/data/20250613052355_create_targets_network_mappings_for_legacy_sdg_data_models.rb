# frozen_string_literal: true

class CreateTargetsNetworkMappingsForLegacySdgDataModels < ActiveRecord::Migration[8.0]
  MAPPINGS =  {
    1 => {
      1  => %w[1.1 1.2 1.3 1.4 1.5],
      2  => %w[2.1 2.3],
      3  => %w[3.8 3.9],
      6  => %w[6.1],
      7  => %w[7.1 7.2],
      10 => %w[10.1 10.4],
      11 => %w[11.1 11.2 11.5],
      13 => %w[13.1]
    },
    2 => {
      2  => %w[2.1 2.2 2.3 2.4 2.5],
      6  => %w[6.4],
      12 => %w[12.3],
      15 => %w[15.3 15.6]
    },
    3 => {
      2  => %w[2.2],
      3  => %w[3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9],
      6  => %w[6.1 6.2 6.3],
      11 => %w[11.2 11.5],
      12 => %w[12.4]
    },
    4 => {
      3  => %w[3.7],
      4  => %w[4.1 4.2 4.3 4.4 4.5 4.6 4.7],
      5  => %w[5.6],
      12 => %w[12.8],
      13 => %w[13.3]
    },
    5 => {
      1 => %w[1.4],
      2 => %w[2.2],
      3 => %w[3.7],
      4 => %w[4.1 4.2 4.3 4.5 4.6 4.7],
      5 => %w[5.1 5.2 5.3 5.4 5.5 5.6],
      6 => %w[6.2]
    },
    6 => {
      3 => %w[3.9],
      6 => %w[6.1 6.2 6.3 6.4 6.5 6.6]
    },
    7 => {
      3  => %w[3.9],
      7  => %w[7.1 7.2 7.3],
      12 => %w[12.5]
    },
    8 => {
      2  => %w[2.3 2.4],
      4  => %w[4.4],
      8  => %w[8.1 8.2 8.3 8.4 8.5 8.6 8.7 8.8 8.9 8.10],
      9  => %w[9.1 9.2 9.3],
      14 => %w[14.7]
    },
    9 => {
      9 => %w[9.1 9.2 9.3 9.4 9.5]
    },
    10 => {
      1  => %w[1.3 1.4],
      2  => %w[2.3],
      3  => %w[3.8],
      4  => %w[4.5],
      5  => %w[5.1 5.4 5.5],
      6  => %w[6.1],
      7  => %w[7.1],
      8  => %w[8.8],
      9  => %w[9.1],
      10 => %w[10.1 10.2 10.3 10.4 10.5 10.6 10.7],
      11 => %w[11.1 11.7],
      15 => %w[15.6],
      16 => %w[16.8]
    },
    11 => {
      3  => %w[3.6 3.9],
      6  => %w[6.1],
      11 => %w[11.1 11.2 11.3 11.4 11.5 11.6 11.7]
    },
    12 => {
      2  => %w[2.4],
      4  => %w[4.7],
      6  => %w[6.4],
      7  => %w[7.2 7.3],
      8  => %w[8.4],
      9  => %w[9.4],
      11 => %w[11.2 11.6],
      12 => %w[12.1 12.2 12.3 12.4 12.5 12.6 12.7 12.8],
      14 => %w[14.1],
      15 => %w[15.6]
    },
    13 => {
      1  => %w[1.5],
      2  => %w[2.4],
      6  => %w[6.3],
      13 => %w[13.1 13.2 13.3],
      15 => %w[15.2]
    },
    14 => {
      14 => %w[14.1 14.2 14.3 14.4 14.5 14.6 14.7]
    },
    15 => {
      2  => %w[2.4 2.5],
      6  => %w[6.6],
      15 => %w[15.1 15.2 15.3 15.4 15.5 15.6 15.7 15.8 15.9],
    },
    16 => {
      4  => %w[4.7],
      5  => %w[5.1 5.2 5.5],
      8  => %w[8.7],
      10 => %w[10.2 10.3 10.6],
      11 => %w[11.3],
      16 => %w[16.1 16.2 16.3 16.4 16.5 16.6 16.7 16.8 16.9 16.10]
    }
  }

  def up
    data_models.each do |data_model|
      next if data_model.targets_network_mappings.exists?

      focus_areas = data_model.focus_areas.to_a
      characteristics = data_model.characteristics.to_a

      MAPPINGS.each do |goal_code, networks|
        focus_area = focus_areas.find { |focus_area| focus_area.code == goal_code.to_s }

        networks.each do |_, target_codes|
          target_codes.each do |target_code|

            characteristic = characteristics.find { |characteristic| characteristic.code == target_code }
            next unless characteristic && focus_area

            TargetsNetworkMapping.create(
              characteristic_id: characteristic.id,
              focus_area_id: focus_area.id,
              data_model_id: data_model.id
            )
          end
        end
      end
    end
  end

  def down
    data_models.each do |data_model|
      data_model.targets_network_mappings.delete_all
    end
  end

  private

  def data_models
    DataModel.where(name: 'Sustainable Development Goals')
  end
end


