class CommonIncidentTypesController < ApplicationController
  def search
    authorize! :index, :common_incident_types

    if params[:q].blank?
      @results = []
    else
      term = "%#{params[:q]&.downcase}%"
      @results = CommonIncidentType.where("lower(code) LIKE ?", term).or(
        CommonIncidentType.where("lower(notes) LIKE ?", term).or(
          CommonIncidentType.where("lower(description) LIKE ?", term),
        ),
      )
    end

    render layout: false
  end
end
