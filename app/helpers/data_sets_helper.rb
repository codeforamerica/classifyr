module DataSetsHelper
  def completed_card_class(data_set)
    return "bg-gray-50" if data_set.completed?

    "bg-white"
  end
end
