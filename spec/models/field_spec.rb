# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Field, type: :model do
  let(:field) { build(:field) }

  include_examples 'valid factory', :field
  include_examples 'papertrail versioning', :field, 'position'
  include_examples 'associations', :field, %i[data_set unique_values]

  describe 'constants' do
    it 'has the TYPES constant defined' do
      expect(Field::TYPES).to eq(
        [
          '', 'Emergency Category', 'Call Category', Classification::CALL_TYPE,
          '-----------------', 'Call Identifier', 'Call Time', 'Call Disposition', 'Priority', 'Dispatched Unit Type',
          '-----------------', 'Geolocation Latitude', 'Geolocation Longitude',
          '-----------------', 'Flag Alcohol Related', 'Flag Domestic Violence', 'Flag Drug Related',
          'Flag Mental Health'
        ]
      )
    end

    it 'has the VALUE_TYPES constant defined' do
      expect(Field::VALUE_TYPES).to eq(['Emergency Category', 'Call Category', Classification::CALL_TYPE,
                                        'Call Disposition', 'Priority'])
    end
  end

  describe 'class methods' do
    describe '.mapped' do
      it 'returns mapped fields' do
        mapped_field = create(:field, common_type: Field::VALUE_TYPES[1])
        create(:field, common_type: nil)

        expect(described_class.mapped).to eq [mapped_field]
      end
    end
  end

  describe 'instance methods' do
    describe '#values?' do
      context 'without a common_type' do
        it 'returns true' do
          field = create(:field, common_type: Field::VALUE_TYPES[1])
          expect(field.values?).to be true
        end
      end

      context 'with a common_type' do
        it 'returns false' do
          field = create(:field, common_type: nil)
          expect(field.values?).to be false
        end
      end
    end

    describe '#pick_value_to_classify_for' do
      context 'when unique_values.any? is true' do
        it 'returns the first available unique_value for the given user' do
          role = create(:role)
          jack = create(:user, role:)
          john = create(:user, role:)

          field = create(:field, common_type: Classification::CALL_TYPE)

          unique_value_1 = create(:unique_value, field:) # already classified by jack
          unique_value_2 = create(:unique_value, field:, classifications_count: 3) # completed
          unique_value_3 = create(:unique_value, field:, classifications_count: 2)
          # lowest amount of classifications
          unique_value_4 = create(:unique_value, field:, classifications_count: 1)

          create(:classification, unique_value: unique_value_1, user: jack)
          create(:classification, unique_value: unique_value_2, user: john)
          create(:classification, unique_value: unique_value_3, user: john)

          expect(field.pick_value_to_classify_for(jack)).to eq unique_value_4
        end
      end

      context 'when unique_values.any? is false' do
        it 'returns nil' do
          jack = create(:user)
          field = create(:field, common_type: Classification::CALL_TYPE)

          expect(field.pick_value_to_classify_for(jack)).to be_nil
        end
      end
    end
  end
end
