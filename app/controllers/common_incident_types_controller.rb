# frozen_string_literal: true

# Rails controller for common incident types.
class CommonIncidentTypesController < ApplicationController
  def search
    authorize! :index, :common_incident_types

    @results = nil
    @results = CommonIncidentType.search(params[:q]).to_a if params[:q].present?

    render layout: false
  end
end
