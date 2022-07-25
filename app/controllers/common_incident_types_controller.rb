class CommonIncidentTypesController < ApplicationController
  def search
    term = "%#{params[:q]&.downcase}%"
    @results = CommonIncidentType.where("lower(code) LIKE ?", term).or(
      CommonIncidentType.where("lower(notes) LIKE ?", term).or(
        CommonIncidentType.where("lower(description) LIKE ?", term),
      ),
    )
    render layout: false
  end
end
