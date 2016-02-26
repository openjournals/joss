module PapersHelper
  def selected_class(tab_name)
    if controller.action_name == tab_name
      "selected"
    end
  end

  def state_badge_for(paper)
    return 'badges/unknown.svg' unless paper

    case paper.state
      when "submitted"
        'badges/submitted.svg'
      when "under_review"
        'badges/under_review.svg'
      when "review_completed"
        'badges/review_completed.svg'
      when "accepted"
        'badges/accepted.svg'
      when "rejected"
        'badges/rejected.svg'
      else
        'badges/unknown.svg'
    end
  end
end
