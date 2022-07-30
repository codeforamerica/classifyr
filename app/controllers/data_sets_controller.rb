class DataSetsController < ApplicationController
  before_action :set_data_set, only: %i[show edit update destroy map analyze]

  def index
    authorize! :index, :data_sets
    @data_sets = DataSet.all
  end

  def show
    authorize! :show, :data_sets
  end

  def new
    authorize! :create, :data_sets
    @data_set = DataSet.new
  end

  def edit
    authorize! :update, :data_sets
  end

  def create
    authorize! :create, :data_sets
    @data_set = DataSet.new(data_set_params)

    if @data_set.save
      redirect_to map_data_set_path(@data_set), notice: "DataSet was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize! :update, :data_sets
    if params["data_set"]["step"] == "map_fields"
      params["data_set"]["common_types"].each do |position, common_type|
        common_type = nil if common_type.blank?
        @data_set.fields.find_by(position:).update(common_type:)
      end
      redirect_to analyze_data_set_url(@data_set), notice: "Fields were successfully mapped."
    elsif @data_set.update(data_set_params)
      redirect_to data_set_url(@data_set), notice: "Data set was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! :destroy, :data_sets
    @data_set.destroy

    redirect_to data_sets_url, notice: "Data set was successfully destroyed."
  end

  def map
    authorize! :create, :data_sets
    @data_set.prepare_datamap
    @fields = @data_set.fields.order("position asc")
  end

  def analyze
    authorize! :create, :data_sets
    @data_set.analyze! unless @data_set.analyzed?
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_data_set
    @data_set = DataSet.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def data_set_params
    params.require(:data_set).permit(
      :title, :data_link, :api_links, :source, :exclusions, :license, :format,
      :documentation_link, :city, :state, :description, :has_911, :has_ems,
      :has_fire, files: []
    )
  end
end
