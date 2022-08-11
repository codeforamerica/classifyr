class CallTypesController < ApplicationController
  before_action :set_data_set, only: [:index]
  before_action :disable_turbo, only: [:index]
  before_action :set_breadcrumbs

  def index
    authorize! :index, :call_types

    add_breadcrumb("Call Types", call_types_classifications_path)
    add_breadcrumb(@data_set.title)

    @fields = @data_set.fields.order(:position)
    @field = @data_set.pick_random_field

    @term = @field.pick_random_value
    @data = @term&.examples
    @classification = @term ? Classification.new(value: @term.value, common_type: Classification::CALL_TYPE) : nil

    # @common_incident_types = CommonIncidentType.all.order(:code).to_h do |cit|
    #   ["#{cit.code}: #{cit.notes || cit.description}", cit.id]
    # end
  end

  private

  def set_data_set
    @data_set = DataSet.find(params[:data_set_id])
  end

  def set_breadcrumbs
    add_breadcrumb("Classification", call_types_classifications_path)
  end
end
