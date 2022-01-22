module InitiativesHelper

  def scorecard_label(initiative)
    if initiative.new_record? || initiative.scorecard.nil?
      Scorecard.model_name.human
    else
      safe_join([
        content_tag(:span, "#{Scorecard.model_name.human}", style: 'margin-right: 10px'),
        link_to(
          content_tag(
            :i,
            '',
            class: "fa fa-external-link"
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
      safe_join([content_tag(:i, '', class: "fa fa-youtube-play")])
    end
  end
end
