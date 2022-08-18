class CommonIncidentTypesController < ApplicationController
  def search
    authorize! :index, :common_incident_types

    if params[:q].blank?
      @results = []
      @show_unknown = false
    else
      @results = CommonIncidentType.search("%#{params[:q]&.downcase}%")

      @show_unknown = true if @results.none?
    end

    render layout: false
  end
end
