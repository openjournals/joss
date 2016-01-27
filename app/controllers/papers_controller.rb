class PapersController < ApplicationController
  before_filter :require_user, :only => [ :new, :edit, :create, :submit, :update ]

  def new
    @paper = Paper.new
  end
end
