require "rails_helper"

RSpec.describe UniqueValue, type: :model do
  include_examples "valid factory", :unique_value
  include_examples "papertrail versioning", :unique_value, "value"
  include_examples "associations", :unique_value, [:field]
end
