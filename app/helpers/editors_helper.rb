module EditorsHelper
  # methods to compute availability of an editor based on
  # @assignment_by_editor and @paused_by_editor
  def display_availability(editor)
    active_assignments = @assignment_by_editor[editor.id].to_i - @paused_by_editor[editor.id].to_i
    availability = editor.max_assignments - active_assignments
    icon = if availability <= 0
             "🟥"
           elsif availability == 1
              "🟨"
           else
              "🟩"
           end

    comment = "#{editor.max_assignments} max."
    if editor.availability_comment.present?
      icon += "*"
      comment += " : #{editor.availability_comment}"
    end

    "<span title='#{comment}' %>#{icon}</span>".html_safe
  end

  def in_progress_for_editor(editor)
    paused_count = @paused_by_editor[editor.id].to_i
    total_paper_count = @assignment_by_editor[editor.id].to_i

    if paused_count > 0
      return "#{total_paper_count - paused_count} <span class='small font-italic'>(+ #{paused_count})</span>".html_safe
    else
      return "#{total_paper_count}"
    end
  end

  def in_progress_no_paused_for_editor(editor)
    paused_count = @paused_by_editor[editor.id].to_i
    total_paper_count = @assignment_by_editor[editor.id].to_i

    return total_paper_count - paused_count
  end

  def availability_class(editor)
    active_assignments = @assignment_by_editor[editor.id].to_i - @paused_by_editor[editor.id].to_i
    availability = editor.max_assignments - active_assignments
    if availability <= 0
     "availability-none"
    elsif availability == 1
      "availability-somewhat"
    else
      ""
    end
  end
  
  def in_progress_no_paused_for_editor(editor)
    paused_count = @paused_by_editor[editor.id].to_i
    total_paper_count = @assignment_by_editor[editor.id].to_i

    return total_paper_count - paused_count
  end

  def open_invites_for_editor(editor)
    invites = editor.invitations.pending

    return "–" if invites.empty?

    output = []
    invites.each do |invite|
      output << link_to(invite.paper.meta_review_issue_id, invite.paper.meta_review_url)
    end

    return output.join(" • ").html_safe
  end
end
