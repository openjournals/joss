module PapersHelper
  def selected_class(tab_name)
    if controller.action_name == tab_name
      "selected"
    end
  end
end
