require "rails_helper"

feature "Table of Contents" do
  before do
    parsed_launch_date = Time.parse(Rails.application.settings[:launch_date])
    @launch_year = parsed_launch_date.year
    @launch_month = parsed_launch_date.month

    @now = Time.now

    @current_volume = @now.year - @launch_year + 1
    @current_issue = 12 * (@now.year - @launch_year) + @now.month - @launch_month + 1

    @years = (@launch_year..@now.year).to_a
    @volumes = (1..@current_volume).to_a
    @issues = (1..@current_issue).to_a


    @first_accepted_paper = create(:accepted_paper, title: "Paper number 1", accepted_at: parsed_launch_date)
    @retracted_paper = create(:retracted_paper, title: "Bad paper", accepted_at: @now)
    @last_accepted_paper = create(:accepted_paper, title: "Research paper 2", accepted_at: @now)

    @first_accepted_paper.metadata["paper"]["year"] = @launch_year
    @first_accepted_paper.metadata["paper"]["volume"] = 1
    @first_accepted_paper.metadata["paper"]["issue"] = 1
    @first_accepted_paper.metadata["paper"]["page"] = 1
    @first_accepted_paper.save!

    @retracted_paper.metadata["paper"]["year"] = @now.year
    @retracted_paper.metadata["paper"]["volume"] = @current_volume
    @retracted_paper.metadata["paper"]["issue"] = @current_issue
    @retracted_paper.metadata["paper"]["page"] = 2
    @retracted_paper.save!

    @last_accepted_paper.metadata["paper"]["year"] = @now.year
    @last_accepted_paper.metadata["paper"]["volume"] = @current_volume
    @last_accepted_paper.metadata["paper"]["issue"] = @current_issue
    @last_accepted_paper.metadata["paper"]["page"] = 3
    @last_accepted_paper.save!

    Paper.reindex
  end

  scenario "index" do
    visit toc_index_path

    within("#toc-header") do
      expect(page).to have_content("Table of Contents")
      expect(page).to_not have_link("Table of Contents")
    end

    @volumes.each do |volume|
      expect(page).to have_link("Volume #{volume} (#{@years[@volumes.index(volume)]})", href: toc_volume_path(volume: volume))
    end

    @issues.each do |issue|
      expect(page).to have_link("Issue #{issue.to_s.rjust(3, "0")}", href: toc_issue_path(issue: issue))
    end

    expect(page).to have_link("Current issue", href: toc_current_issue_path)
  end

  scenario "by year" do
    visit toc_year_path(year: @years.first)
    within("#toc-header") do
      expect(page).to have_content("Year #{@years.first}")
      expect(page).to have_link("Table of Contents")
    end
    expect(page).to have_link(@first_accepted_paper.title, href: @first_accepted_paper.seo_url)
    expect(page).to_not have_link(@retracted_paper.title)
    expect(page).to_not have_link(@last_accepted_paper.title)

    visit toc_year_path(year: @years.last)
    within("#toc-header") do
      expect(page).to have_content("Year #{@years.last}")
      expect(page).to have_link("Table of Contents")
    end
    expect(page).to have_link(@retracted_paper.title, href: @retracted_paper.seo_url)
    expect(page).to have_link(@last_accepted_paper.title, href: @last_accepted_paper.seo_url)
    expect(page).to_not have_link(@first_accepted_paper.title)
  end

  scenario "by volume" do
    visit toc_volume_path(volume: 1)
    within("#toc-header") do
      expect(page).to have_content("Year #{@years.first}")
      expect(page).to have_content("Volume 1")
      expect(page).to have_link("Table of Contents")
    end
    expect(page).to have_link(@first_accepted_paper.title, href: @first_accepted_paper.seo_url)
    expect(page).to_not have_link(@retracted_paper.title)
    expect(page).to_not have_link(@last_accepted_paper.title)

    visit toc_volume_path(volume: @volumes.last)
    within("#toc-header") do
      expect(page).to have_content("Year #{@years.last}")
      expect(page).to have_content("Volume #{@volumes.last}")
      expect(page).to have_link("Table of Contents")
    end
    expect(page).to have_link(@retracted_paper.title, href: @retracted_paper.seo_url)
    expect(page).to have_link(@last_accepted_paper.title, href: @last_accepted_paper.seo_url)
    expect(page).to_not have_link(@first_accepted_paper.title)
  end

  scenario "by issue" do
    visit toc_issue_path(issue: 1)
    within("#toc-header") do
      expect(page).to have_content("#{Date::MONTHNAMES[@launch_month]} #{@years.first} Volume 1")
      expect(page).to have_content("Issue 1")
      expect(page).to have_link("Table of Contents")
    end
    expect(page).to have_link(@first_accepted_paper.title, href: @first_accepted_paper.seo_url)
    expect(page).to_not have_link(@retracted_paper.title)
    expect(page).to_not have_link(@last_accepted_paper.title)

    visit toc_issue_path(issue: @issues.last)
    within("#toc-header") do
      expect(page).to have_content("#{Date::MONTHNAMES[@now.month]} #{@years.last} Volume #{@volumes.last}")
      expect(page).to have_content("Issue #{@issues.last}")
      expect(page).to have_link("Table of Contents")
    end
    expect(page).to have_link(@retracted_paper.title, href: @retracted_paper.seo_url)
    expect(page).to have_link(@last_accepted_paper.title, href: @last_accepted_paper.seo_url)
    expect(page).to_not have_link(@first_accepted_paper.title)

    visit toc_issue_path(issue: @issues[2])

    expect(page).to_not have_link(@first_accepted_paper.title)
    expect(page).to_not have_link(@retracted_paper.title)
    expect(page).to_not have_link(@last_accepted_paper.title)
  end

  scenario "current issue" do
    visit toc_current_issue_path
    within("#toc-header") do
      expect(page).to have_content("Current issue")
      expect(page).to have_content("Year #{@years.last} Volume #{@volumes.last} Issue #{@issues.last}")
      expect(page).to have_link("Table of Contents")
    end
    expect(page).to have_link(@retracted_paper.title, href: @retracted_paper.seo_url)
    expect(page).to have_link(@last_accepted_paper.title, href: @last_accepted_paper.seo_url)
    expect(page).to_not have_link(@first_accepted_paper.title)
  end
end
