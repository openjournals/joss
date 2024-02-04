module EditorsHelper
  # methods to compute availability of an editor based on
  # @assignment_by_editor and @paused_by_editor
  def display_availability(editor)
    active_assignments = @assignment_by_editor[editor.id].to_i - @paused_by_editor[editor.id].to_i
    availability = editor.max_assignments - active_assignments
    icon = if availability <= 0
             "red"
           elsif availability == 1
              "yellow"
           else
              "green"
           end

    availability_class = "availability-status-#{icon}"

    comment = "#{editor.max_assignments} max."

    display_count = "#{active_assignments} / #{editor.max_assignments}"

    if editor.availability_comment.present?
      display_count = "#{active_assignments} / #{editor.max_assignments}*"
      comment += " : #{editor.availability_comment}"
    end
    

    "<span class='#{availability_class}' title='#{comment}' %>#{display_count}</span>".html_safe
  end

  def availability_remaining(editor)
    active_assignments = @assignment_by_editor[editor.id].to_i - @paused_by_editor[editor.id].to_i
    availability = editor.max_assignments - active_assignments

    return "#{availability}"
  end

  def active_assignments_for_editor(editor)
    active_assignments = @assignment_by_editor[editor.id].to_i - @paused_by_editor[editor.id].to_i
    return "#{active_assignments}"
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
    return "–" if @pending_invitations_by_editor[editor.id].to_i == 0

    output = []
    @pending_invitations.each do |invite|
      if invite.editor_id == editor.id
        output << link_to(invite.paper.meta_review_issue_id, invite.paper.meta_review_url)
      end
    end

    return output.join(" • ").html_safe
  end
end
