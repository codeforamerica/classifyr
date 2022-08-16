class Classifications::CallTypesController < ApplicationController
  before_action :set_data_set, only: [:index, :create]
  before_action :disable_turbo, only: [:index, :create]
  before_action :set_breadcrumbs

  def index
    authorize! :create, :classifications
    add_breadcrumb("Call Types", call_types_classifications_path)
    add_breadcrumb(@data_set.title)

    @fields = @data_set.fields.order(:position)
    @field = @data_set.call_type_field

    @term = @field.pick_value_to_classify_for(current_user)
    @data = @term&.examples
    @common_incident_types = []

    @classification = Classification.new(
      unique_value: @term, value: @term.value,
      common_type: Classification::CALL_TYPE, user: current_user
    )
  end

  def create
    authorize! :create, :classifications

    @classification = Classification.new(classification_params)
    @success = @classification.save
  end

  private

  def classification_params
    params.require(:classification).permit(
      :common_type, :unknown,
      :common_incident_type_id, :confidence_rating,
      :confidence_reasoning, :user_id,
      :unique_value_id, :value
    )
  end

  def set_data_set
    @data_set = DataSet.find(params[:data_set_id])
  end

  def set_breadcrumbs
    add_breadcrumb("Classification", call_types_classifications_path)
  end
end
