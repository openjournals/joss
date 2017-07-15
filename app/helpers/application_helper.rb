module ApplicationHelper
  def flash_class_for(flash_level)
    case flash_level
    when 'error'
      'flash-error'
    when 'warning'
      'flash-warn'
    when 'notice'
      'flash-messages'
    else
      'flash-messages'
    end
  end

  def nav_link(link_text, link_path)
    class_name = current_page?(link_path) ? 'active' : ''

    content_tag(:li, class: class_name) do
      link_to link_text, link_path
    end
  end

  # Decide whether to show the 'update your profile' link
  def show_profile_banner?
    return false unless current_user
    return false if controller.action_name == 'profile'

    return false if current_user.profile_complete?
    return true
  end
end
