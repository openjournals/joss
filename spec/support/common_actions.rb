module CommonActions
  def login_as(user)
    allow_any_instance_of(ApplicationController).
      to receive(:current_user).and_return(user)
  end

  def logout
    allow_any_instance_of(ApplicationController).
      to receive(:current_user).and_return(nil)
  end

  def skip_paper_repo_url_check
    # Do not run git ls-remote command from paper.check_repository_address
    # on paper creation.
    # Allowed values in specs are ok, anything else no_ok
    ok = OpenStruct.new(success?: true)
    no_ok = OpenStruct.new(success?: false)
    allow(Open3).to receive(:capture3).and_return(["", "", no_ok ])
    allow(Open3).to receive(:capture3).with("git ls-remote http://github.com/arfon/fidgit").and_return(["", "", ok ])
    allow(Open3).to receive(:capture3).with("git ls-remote https://github.com/openjournals/joss").and_return(["", "", ok ])
    allow(Open3).to receive(:capture3).with("git ls-remote https://github.com/openjournals/joss-reviews").and_return(["", "", ok ])
  end

  def disable_feature(feat, &block)
    previous_value = Rails.application.settings.dig(:features, feat.to_sym)
    Rails.application.settings[:features][feat.to_sym] = false
    if block_given?
      yield
      Rails.application.settings[:features][feat.to_sym] = previous_value
    end
  end

  def enable_feature(feat, &block)
    previous_value = Rails.application.settings.dig(:features, feat.to_sym)
    Rails.application.settings[:features][feat.to_sym] = true
    if block_given?
      yield
      Rails.application.settings[:features][feat.to_sym] = previous_value
    end
  end
end
