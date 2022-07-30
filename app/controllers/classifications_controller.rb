class ClassificationsController < ApplicationController
  def index
    authorize! :index, :classifications

    @term = Classification.pick
    @headings = @term.field.data_set.fields.order(:position).pluck(:heading)
    @data = @term.examples
    @common_incident_types = CommonIncidentType.all.order(:code).to_h do |cit|
      ["#{cit.code}: #{cit.notes || cit.description}", cit.id]
    end

    @classification = Classification.new(value: @term.value, common_type: Classification::CALL_TYPE)
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
end
