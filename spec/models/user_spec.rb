require "rails_helper"

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  describe "factory" do
    it "has a valid factory" do
      expect(user).to be_valid
    end
  end

  describe "versioning" do
    it "has versioning enabled on create" do
      user = create(:user)
      user.update(confirmed_at: Time.zone.now)
      expect(user.versions.count).to eq(2)
      expect(user.versions.last.object_changes).to include("confirmed_at")
    end
  end
end
