module EditorsHelper
  def display_availability(editor)
    icon = case editor.availability
            when 'none'
              "🔴"
            when 'somewhat'
              "🟠"
            else
              "🟢"
           end
    if editor.availability_comment.present?
      icon += "*"
      comment = ": #{editor.availability_comment}"
    end

    "<span title='#{editor.availability.try(:capitalize)}#{comment}' %>#{icon}</span>".html_safe
  end

  def in_progress_for_editor(editor)
    paused_count = @paused_by_editor[editor.id].to_i
    total_paper_count = @assignment_by_editor[editor.id].to_i

    if paused_count > 0
      return "#{total_paper_count - paused_count} <span class='small font-italic'>(+ #{paused_count} paused)</span>".html_safe
    else
      return "#{total_paper_count}"
    end
  end

  def in_progress_no_paused_for_editor(editor)
    paused_count = @paused_by_editor[editor.id].to_i
    total_paper_count = @assignment_by_editor[editor.id].to_i

    return total_paper_count - paused_count
  end
end
