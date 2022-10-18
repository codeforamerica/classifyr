# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Classification, type: :model do
  include_examples 'valid factory', :classification
  include_examples 'papertrail versioning', :classification, 'value'
  include_examples 'associations', :classification, %i[
    common_incident_type
    user
    unique_value
  ]

  describe 'constants' do
    it 'has the TYPES constant defined' do
      expect(Classification::CALL_TYPE).to eq('Detailed Call Type')
    end
  end

  describe 'enum' do
    context 'when confidence_rating is an integer' do
      it 'saves the confidence_rating' do
        classification = create(:classification)
        classification.confidence_rating = 1
        classification.save

        expect(classification.confidence_rating).to eq('Somewhat Confident')
      end
    end
  end

  describe 'callbacks' do
    describe '#update_data_set_completion' do
      context 'with associated unique_value' do
        it 'calls update_completion on the related data_set' do
          classification = build(:classification)
          allow(classification.unique_value).to receive(:update_approval_status)
          allow(classification.unique_value.field.data_set).to receive(:update_completion)

          classification.save
          expect(classification.unique_value).to have_received(:update_approval_status)
          expect(classification.unique_value.field.data_set).to have_received(:update_completion)
        end
      end

      context 'without associated unique_value' do
        it 'does nothing' do
          classification = build(:classification, unique_value: nil)
          allow(classification.unique_value).to receive(:update_approval_status)

          classification.save
          expect(classification.unique_value).not_to have_received(:update_approval_status)
        end
      end
    end
  end
end
