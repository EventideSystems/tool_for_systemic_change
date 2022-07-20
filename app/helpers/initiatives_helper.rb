# frozen_string_literal: true

module InitiativesHelper
  def scorecard_label(initiative)
    if initiative.new_record? || initiative.scorecard.nil?
      current_account.scorecard_types.map { |type| type.model_name.human }.join(' / ')
    else
      safe_join([
                  content_tag(:span, initiative.scorecard.model_name.human.to_s, style: 'margin-right: 10px'),
                  link_to(
                    content_tag(
                      :i,
                      '',
                      class: 'fa fa-external-link'
                    ),
                    transition_card_path(initiative.scorecard),
                    id: 'initiative-detail-scorecard-link'
                  )
                ])
    end
  end

  def initiatives_characteristics_title(initiative)
    case initiative.scorecard.type
    when 'TransitionCard' then 'Initiative Characteristics'
    when 'SustainableDevelopmentGoalAlignmentCard' then 'Initiative SDGs Targets'
    end
  end

  def link_to_video_tutorial(video_tutorial)
    return '' if video_tutorial.blank?

    link_to(
      video_tutorial_path(video_tutorial),
      class: 'video-tutorial-wrapper',
      data: {
        video_tutorial_link: video_tutorial_path(video_tutorial),
        video_tutorial_title: video_tutorial.name
      }
    ) do
      safe_join([content_tag(:i, '', class: 'fa fa-youtube-play')])
    end
  end

  def linked_initiative_warning(initiative)
    return '' if initiative.blank?
    return '' if initiative.scorecard.blank?

    return '' unless initiative.new_record?
    return '' unless initiative.scorecard.linked?
    return '' if initiative.linked_initiative.present?

    content_tag(:div, class: 'form-group row alert alert-warning') do
      content_tag(:strong, 'Note: ', class: 'mr-1') +
        "This initiative belongs to a linked #{initiative.scorecard.model_name.human}. " \
        'Saving this initiative will automaically create a linked initiative in the other card.'
    end
  end

  def initiative_tab_title(scorecard_type)
    case scorecard_type.name
    when 'TransitionCard' then 'Initiatives for Transition Cards'
    when 'SustainableDevelopmentGoalAlignmentCard' then 'Initiatives for SDGs Alignment Cards'
    end
  end

  def initiative_scope(scorecard_type)
    case scorecard_type.name
    when 'TransitionCard' then :transition_cards
    when 'SustainableDevelopmentGoalAlignmentCard' then :sdgs_alignment_cards
    end
  end

  def initiative_tab_class(scorecard_type, scope)
    case scorecard_type.name
    when 'TransitionCard'
      scope.blank? || scope == 'transition_cards' ? 'active' : ''
    when 'SustainableDevelopmentGoalAlignmentCard'
      scope == 'sdgs_alignment_cards' ? 'active' : ''
    end + ' nav-link'
  end

  def initiative_scorecard_types
    current_account.scorecard_types.map do |scorecard_type|
      [scorecard_type.model_name.human.pluralize, scorecard_type.name]
    end
  end

  def initiative_export_button_tooltip_title(params)
    if current_account.scorecard_types.count > 1
      "Export #{initiative_tab_title(scorecard_type_from_params(params))} to CSV"
    else
      'Export Initiatives to CSV'
    end
  end

  private

  # SMELL: Duplicate of code in initiatives_controller.rb
  def scorecard_type_from_params(params)
    if params[:scope].blank? || !params[:scope].in?(%w[transition_cards sdgs_alignment_cards])
      current_account.default_scorecard_type
    else
      case params[:scope].to_sym
      when :sdgs_alignment_cards then SustainableDevelopmentGoalAlignmentCard
      when :transition_cards then TransitionCard
      end
    end
  end
end
