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
          scorecard_path(initiative.scorecard), 
          id: 'initiative-detail-scorecard-link'
        )
      ])
    end
  end    
end
