class ClassificationsController < ApplicationController
  def index
    @term = Classification.pick
    @headings = @term.field.data_set.fields.order(:position).pluck(:heading)
    @data = @term.examples
    @common_incident_types = CommonIncidentType.all.order(:code).map do |cit|
      ["#{cit.code}: #{cit.notes || cit.description}", cit.id]
    end.to_h

    @classification = Classification.new(value: @term.value, common_type: Classification::CALL_TYPE)
  end

  def create
    @classification = Classification.new(classification_params)

    if @classification.save && ! @classification.unknown?
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
