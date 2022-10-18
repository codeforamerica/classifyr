# frozen_string_literal: true

# Rails controller for data classifications.
class ClassificationsController < ApplicationController
  before_action :set_breadcrumbs

  def index
    authorize! :index, :classifications
    redirect_to call_types_classifications_path
  end

  def call_types
    authorize! :index, :classifications
    add_breadcrumb('Call Types', call_types_classifications_path)

    # Select data_sets that have at least one field with
    # common_type = Classification::CALL_TYPE
    @data_sets = DataSet.to_classify.page(params[:page] || 1).per(8)
  end

  private

  def set_breadcrumbs
    add_breadcrumb('Classification', call_types_classifications_path)
  end
end
