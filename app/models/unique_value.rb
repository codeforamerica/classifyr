class UniqueValue < ApplicationRecord
  belongs_to :field

  def examples
    data = []
    field.data_set.datafile.with_file do |f|
      data = `tail -n +2 #{f.path} | grep "#{value}" | head -5`&.split("\n")&.map do |line|
        line.split(",")
      end
    end

    data
  end
end
