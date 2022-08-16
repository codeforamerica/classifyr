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
      .order(completion_percent: :asc, created_at: :asc)
      .page(params[:page] || 1).per(8)
  end

  private

  def set_breadcrumbs
    add_breadcrumb("Classification", call_types_classifications_path)
  end
end
