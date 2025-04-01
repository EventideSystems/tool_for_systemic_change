# frozen_string_literal: true

class CreateImpactCardDataModels < ActiveRecord::Migration[8.0]
  def up
    Workspace.all.each do |workspace|
      impact_card_data_model = sdgs_impact_card_data_model(workspace)

      update_scorecards(workspace, 'SustainableDevelopmentGoalAlignmentCard', impact_card_data_model)
      update_focus_area_groups(workspace,  'SustainableDevelopmentGoalAlignmentCard', impact_card_data_model)

      if workspace.scorecards.where(type: 'TransitionCard').exists?        
        impact_card_data_model = transition_impact_card_data_model(workspace)

        update_scorecards(workspace, 'TransitionCard', impact_card_data_model)
        update_focus_area_groups(workspace,  'TransitionCard', impact_card_data_model)
      end
    end
  end

  def down
    Scorecard.update_all(impact_card_data_model_id: nil)
    FocusAreaGroup.update_all(impact_card_data_model_id: nil)
    ImpactCardDataModel.delete_all
  end

  private

  def sdgs_impact_card_data_model(workspace)
    workspace.impact_card_data_models.find_or_create_by(name: 'Sustainable Development Goals') do |impact_card_data_model|
      impact_card_data_model.short_name = 'SDGs'
      impact_card_data_model.description = 'United Nations Sustainable Development Goals'
      impact_card_data_model.color = '#2563eb'
      impact_card_data_model.status = 'active'
    end
  end

  def transition_impact_card_data_model(workspace)
    workspace.impact_card_data_models.find_or_create_by(name: 'Transition Card') do |impact_card_data_model|
      impact_card_data_model.short_name = 'Transition'
      impact_card_data_model.description = 'Legacy Transition Card'
      impact_card_data_model.color = '#0d9488'
      impact_card_data_model.status = 'active'
    end
  end

  def update_scorecards(workspace, type, impact_card_data_model)
    workspace.scorecards.where(type:).update_all(impact_card_data_model_id: impact_card_data_model.id)
  end

  def update_focus_area_groups(workspace, scorecard_type, impact_card_data_model)
    workspace.focus_area_groups.where(scorecard_type:).update_all(impact_card_data_model_id: impact_card_data_model.id)
  end
end

