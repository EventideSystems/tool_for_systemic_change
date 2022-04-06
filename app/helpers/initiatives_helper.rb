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
end
