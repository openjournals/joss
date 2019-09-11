Octokit.auto_paginate = true
GITHUB = Octokit::Client.new(access_token: ENV['GH_TOKEN'])
