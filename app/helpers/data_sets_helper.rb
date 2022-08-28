module DataSetsHelper
  def completed_card_class(data_set)
    return "bg-gray-50" if data_set.completed?

    "bg-white"
  end

  def location(data_set)
    return "" unless data_set.city.present? || data_set.state.present?
    return data_set.city if data_set.city.present? && data_set.state.blank?
    return data_set.state if data_set.city.blank? && data_set.state.present?

    "#{data_set.city}, #{data_set.state}"
  end
end
