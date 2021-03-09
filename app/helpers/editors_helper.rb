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
end
