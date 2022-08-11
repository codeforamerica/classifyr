class ClassificationsController < ApplicationController
  before_action :set_breadcrumbs

  def index
    authorize! :index, :classifications
    redirect_to call_types_classifications_path
  end

  def call_types
    authorize! :index, :classifications
    add_breadcrumb("Call Types", call_types_classifications_path)

    # Select data_sets that have at least one field with common_type = Classification::CALL_TYPE
    @data_sets = DataSet
      .joins(:fields)
      .where(fields: { common_type: Classification::CALL_TYPE })
      .order(created_at: :desc)
      .page(params[:page] || 1).per(8)
  end

  def create
    authorize! :create, :classifications

    @classification = Classification.new(classification_params)

    if @classification.save && !@classification.unknown?
      redirect_to classifications_path, notice: "'#{@classification.value}' successfully categorized."
    else
      redirect_to classifications_path, notice: "'#{@classification.value}' marked unknown."
    end
  end

  private

  def classification_params
    params.require(:classification).permit(:value, :common_type, :unknown, :common_incident_type_id)
  end

  def set_breadcrumbs
    add_breadcrumb("Classification", call_types_classifications_path)
  end
end
