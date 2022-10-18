# frozen_string_literal: true

RSpec.shared_examples 'valid factory' do |model|
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(model)).to be_valid
    end
  end
end
