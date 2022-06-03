class SubjectsController < ApplicationController
  def search
    query = params[:q]
    @subjects = Subject.where("name ILIKE ?", "%" + query + "%") if query.present?
    render layout: false
  end
end
