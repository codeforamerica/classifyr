# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  include_examples 'valid factory', :user
  include_examples 'papertrail versioning', :user, 'confirmed_at'

  describe 'FriendlyID' do
    it 'receives a random slug on creation' do
      user = create(:user)
      expect(user.slug).not_to be_nil
    end
  end
end
