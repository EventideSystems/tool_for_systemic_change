# frozen_string_literal: true

class CreateImpactCardDataModels < ActiveRecord::Migration[8.0]
  def up
    Workspace.all.each do |workspace|
      data_model = sdgs_data_model(workspace)

      update_scorecards(workspace, 'SustainableDevelopmentGoalAlignmentCard', data_model)
      update_focus_area_groups(workspace,  'SustainableDevelopmentGoalAlignmentCard', data_model)

      if workspace.scorecards.where(type_key => 'TransitionCard').exists?        
        data_model = transition_data_model(workspace)

        update_scorecards(workspace, 'TransitionCard', data_model)
        update_focus_area_groups(workspace,  'TransitionCard', data_model)
      end
    end
  end

  def down
    Scorecard.with_deleted.update_all(data_model_id: nil)
    FocusAreaGroup.with_deleted.update_all(data_model_id: nil)
    DataModel.where(
      name: ['Transition Card', 'Sustainable Development Goals'],
      system_model: false
    ).each(&:really_destroy!)
  end

  private

  def type_key 
    Scorecard.column_names.include?('deprecated_type') ? :deprecated_type : :type    
  end

  def scorecard_type_key
    Scorecard.column_names.include?('deprecated_type') ? :deprecated_scorecard_type : :scorecard_type
  end

  def sdgs_data_model(workspace)
    workspace.data_models.find_or_create_by(name: 'Sustainable Development Goals') do |data_model|
      data_model.short_name = 'SDGs'
      data_model.description = 'United Nations Sustainable Development Goals'
      data_model.color = '#2563eb'
      data_model.status = 'active'
    end
  end

  def transition_data_model(workspace)
    workspace.data_models.find_or_create_by(name: 'Transition Card') do |data_model|
      data_model.short_name = 'Transition'
      data_model.description = 'Legacy Transition Card'
      data_model.color = '#0d9488'
      data_model.status = 'active'
    end
  end

  def update_scorecards(workspace, type, data_model)
    workspace.scorecards.where(type_key => type).update_all(data_model_id: data_model.id)
  end

  def update_focus_area_groups(workspace, scorecard_type, data_model)
    workspace.focus_area_groups.where(scorecard_type_key => scorecard_type).update_all(data_model_id: data_model.id)
  end
end

