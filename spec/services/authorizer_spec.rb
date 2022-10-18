# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Authorizer, type: :model do
  subject do
    described_class.new(
      user: current_user,
      action:,
      entity:,
      record:
    ).run
  end

  let(:role) { create(:role, name: :data_admin) }
  let(:current_user) { create(:user, role:) }
  let(:action) { :index }
  let(:entity) { :data_sets }
  let(:record) { nil }

  describe '#run' do
    context 'when user does not have a role' do
      let(:role) { nil }

      it { is_expected.to be(false) }
    end

    context 'when no record is passed' do
      context 'when role does not exist in permissions' do
        let(:role) { create(:role, name: :unknown) }

        it { is_expected.to be(false) }
      end

      context 'when role has :all permissions' do
        let(:role) { create(:role, name: :data_admin) }

        it { is_expected.to be(true) }
      end

      context 'when entity is not in permissions' do
        let(:role) { create(:role, name: :volunteer) }
        let(:entity) { :unknown }

        it { is_expected.to be(false) }
      end

      context 'when entity permission is present' do
        let(:role) { create(:role, name: :volunteer) }
        let(:entity) { :data_sets }

        it { is_expected.to be(true) }
      end
    end

    context 'when a record is passed' do
      context 'when policy does not exist' do
        let(:record) { create(:data_set) }

        it { is_expected.to be(true) }
      end

      context 'when policy exists' do
        let(:record) { create(:user) }

        it { is_expected.to be(true) }
      end
    end
  end
end
