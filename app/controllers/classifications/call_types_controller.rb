class Classifications::CallTypesController < ApplicationController
  before_action :set_data_set, only: [:index, :create]
  before_action :disable_turbo, only: [:index, :create]
  before_action :set_breadcrumbs
  before_action :set_index_breacrumbs, only: [:index]

  def index
    authorize! :create, :classifications

    @fields = @data_set.fields.order(:position)
    @term = @data_set.pick_value_to_classify_for(current_user)

    # No unique value left to classify for the current_user,
    # find a unique value from another data_set to classify
    unless @term
      handle_term_not_found
      return
    end

    @data = @term&.examples
    @classification = Classification.new(
      unique_value: @term, value: @term.value, common_type: Classification::CALL_TYPE,
    )
  end

  def create
    authorize! :create, :classifications

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
    @data_set = DataSet.find(params[:data_set_id])

    return unless @data_set.completed?

    redirect_to call_types_classifications_path,
                notice: "This data set has already been fully classified."
  end

  def handle_term_not_found
    value = UniqueValue.to_classify_with_data_set_priority(current_user).first

    if value
      redirect_to classify_data_sets_call_types_classifications_path(value.data_set.id)
    else
      # We couldn't find anything left to classify
      redirect_to call_types_classifications_path,
                  notice: "All current data sets have been fully classified, thank you!"
    end
  end

  def set_breadcrumbs
    add_breadcrumb("Classification", call_types_classifications_path)
  end

  def set_index_breacrumbs
    add_breadcrumb("Call Types", call_types_classifications_path)
    add_breadcrumb(@data_set.title)
  end
end
