require "rails_helper"

RSpec.describe User, type: :model do
  include_examples "valid factory", :user
  include_examples "papertrail versioning", :user, "confirmed_at"
end
