# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy, type: :model do
  let(:role) { create(:role) }
  let(:current_user) { create(:user, role:) }
  let(:user) { create(:user, role:) }

  describe '#show' do
    context 'when current_user != user' do
      let(:policy) { described_class.new(current_user, user) }

      it 'returns true' do
        expect(policy.show).to be(true)
      end
    end

    context 'when current_user == user' do
      let(:policy) { described_class.new(current_user, current_user) }

      it 'returns true' do
        expect(policy.show).to be(false)
      end
    end
  end

  describe '#update' do
    context 'when current_user != user' do
      let(:policy) { described_class.new(current_user, user) }

      it 'returns true' do
        expect(policy.update).to be(true)
      end
    end

    context 'when current_user == user' do
      let(:policy) { described_class.new(current_user, current_user) }

      it 'returns true' do
        expect(policy.update).to be(false)
      end
    end
  end

  describe '#destroy' do
    context 'when current_user != user' do
      let(:policy) { described_class.new(current_user, user) }

      it 'returns true' do
        expect(policy.destroy).to be(true)
      end
    end

    context 'when current_user == user' do
      let(:policy) { described_class.new(current_user, current_user) }

      it 'returns true' do
        expect(policy.destroy).to be(false)
      end
    end
  end
end
