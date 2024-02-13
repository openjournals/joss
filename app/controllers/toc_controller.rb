class TocController < ApplicationController
  include SettingsHelper

  before_action :set_toc_data

  def current_issue
    filter_papers(@issues.last, :issue)
  end

  def year
    filter_papers(params[:year], :year)
  end

  def volume
    filter_papers(params[:volume], :volume)
    @year = @years[params[:volume].to_i - 1]
  end

  def issue
    filter_papers(params[:issue], :issue)
    @volume = volume_for_issue(params[:issue].to_i)
    @year = @years[@volume - 1]
    @month = (params[:issue].to_i - 1 + @launch_month) % 12
    @month = 12 if @month == 0
  end

  private

  def set_toc_data
    parsed_launch_date = Time.parse(setting(:launch_date))
    @launch_year = parsed_launch_date.year
    @launch_month = parsed_launch_date.month

    current_volume = Time.new.year - @launch_year + 1
    current_issue = 12 * (Time.new.year - @launch_year) + Time.new.month - @launch_month + 1

    @years = (@launch_year..Time.new.year).to_a
    @volumes = (1..current_volume).to_a
    @issues = (1..current_issue).to_a

    volumes_as_keys = @volumes.dup
    issues_as_values = @issues.dup
    @issues_by_volume = { volumes_as_keys.shift => issues_as_values.shift(12 - @launch_month + 1)}
    @issues_by_volume.merge! Hash[volumes_as_keys.zip(issues_as_values.in_groups_of(12, false))]
  end

  def volume_for_issue(i)
    @issues_by_volume.each_pair do |volume, issues|
      return volume if issues.include?(i)
    end
    return 0
  end

  def filter_papers(param, field)
    redirect_to(action: :index) and return if param.blank?

    @papers = Paper.search(param.to_i, fields: [{field.to_sym => :exact}], order: { accepted_at: :asc },
                page: params[:page], per_page: 50)
    @pagy = Pagy.new_from_searchkick(@papers)
  end
end
