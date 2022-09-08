class Classifications::CallTypesController < ApplicationController
  before_action :set_data_set, only: [:index]
  before_action :set_call_type, only: [:show, :create]
  before_action :disable_turbo, only: [:show, :create]
  before_action :set_breadcrumbs
  before_action :set_show_breacrumbs, only: [:show]

  def index
    authorize! :create, :classifications

    @call_type = @data_set.pick_value_to_classify_for(current_user)

    unless @call_type
      redirect_to call_types_classifications_path,
                  notice: "You have already classified all call types for this data set."
      return
    end

    redirect_to classify_call_type_classifications_path(slug: @call_type.slug)
  end

  def show
    authorize! :create, :classifications

    @apco_codes = CommonIncidentType.apco
    @data_set = @call_type.data_set
    @fields = @data_set.fields.order(:position)
    @data = @call_type&.examples
    @existing_classication = @call_type.classification_by(current_user)
    @classification = Classification.new(
      unique_value: @call_type, value: @call_type.value, common_type: Classification::CALL_TYPE,
    )
  end

  def create
    authorize! :create, :classifications

    @data_set = @call_type.data_set
    @classification = Classification.new(classification_params)
    @classification.user = current_user
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
    @data_set = find_by_slug_with_history(DataSet, params[:data_set_slug])

    return unless @data_set.completed?

    redirect_to call_types_classifications_path,
                notice: "This data set has already been fully classified."
  end

  def set_call_type
    @call_type = UniqueValue.friendly.find(params[:slug])
  end

  def go_to_next_call_type
    redirect_to call_types_classifications_path,
                notice: "You have already classified all call types for this data set."
  end

  def set_breadcrumbs
    add_breadcrumb("Classification", call_types_classifications_path)
  end

  def set_show_breacrumbs
    add_breadcrumb("Call Types", call_types_classifications_path)
    add_breadcrumb(@call_type.data_set.title)
  end
end
