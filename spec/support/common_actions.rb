module CommonActions
  def login_as(user)
    allow_any_instance_of(ApplicationController).
      to receive(:current_user).and_return(user)
  end

  def logout
    allow_any_instance_of(ApplicationController).
      to receive(:current_user).and_return(nil)
  end
end
