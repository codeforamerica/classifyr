class CommonIncidentTypesController < ApplicationController
  def search
    authorize! :index, :common_incident_types

    @results = nil

    if params[:q].present?
      @results = CommonIncidentType.search("%#{params[:q]&.downcase}%")
    end

    render layout: false
  end
end
