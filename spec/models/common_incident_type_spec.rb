# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonIncidentType do
  let(:common_incident_type) { build(:common_incident_type) }

  include_examples 'valid factory', :common_incident_type
  include_examples 'papertrail versioning', :common_incident_type, 'code'
  include_examples 'associations', :common_incident_type, [:classifications]

  describe 'constants' do
    it 'has the TYPES constant defined' do
      expect(CommonIncidentType::EXPORT_COLUMNS).to eq(%w[id standard version code description notes humanized_code
                                                          humanized_description])
    end
  end

  describe 'class methods' do
    describe '.search' do
      let!(:trespass) { create(:common_incident_type, code: 'TRESPASS', description: 'TRESPASS') }
      let!(:dui) do
        create(:common_incident_type, code: 'DUI', description: 'DUI',
                                      notes: 'Driving while intoxicated, under the influence')
      end
      let!(:fireworks) do
        create(:common_incident_type, code: 'FIREWRKS', description: 'FIREWORKS', notes: 'Illegal use of fireworks')
      end
      let!(:fire_trailer) do
        create(:common_incident_type, code: 'FTRAILER', description: 'FIRE TRAILER',
                                      notes: 'Single wide mobile home fires-double wide should use FIRE STRUCTURE')
      end
      let!(:domestic_non_violent) do
        create(:common_incident_type, code: 'DVNA', description: 'DOMESTIC NON-VIOLENT',
                                      notes: 'Domestic dispute non-violent, verbal')
      end
      let!(:alien) do
        create(:common_incident_type, code: 'ALIEN', description: 'IMMIGRATION',
                                      notes: 'Immigration violation, illegal aliens')
      end
      let!(:wildlife) do
        create(:common_incident_type, code: 'WILDLIFE', description: 'WILDLIFE VIOLATIONS',
                                      notes: 'Illegal hunting, game violations, fisheries')
      end

      context 'when providing a correct partial word (full-text search)' do
        it "returns the expected results for 'iNtOx'" do
          results = described_class.search('iNtOx')

          expect(results.count).to eq(1)
          expect(results.first.id).to eq(dui.id)
        end

        it "returns the expected results for 'viola'" do
          results = described_class.search('viola')

          expect(results.count).to eq(3)
          expect(results.map(&:id)).to eq([
                                            wildlife.id,
                                            alien.id,
                                            domestic_non_violent.id
                                          ])
        end
      end

      context 'when providing a word with a typo' do
        it "returns the expected results for 'traspass'" do
          results = described_class.search('traspass')

          expect(results.count).to eq(1)
          expect(results.first.id).to eq(trespass.id)
        end

        it "returns the expected results for 'firee'" do
          results = described_class.search('firee')

          expect(results.count).to eq(2)
          expect(results.map(&:id)).to eq([
                                            fire_trailer.id,
                                            fireworks.id
                                          ])
        end
      end
    end

    describe '.to_csv' do
      it 'generates a CSV' do
        common_incident_types = create_list(:common_incident_type, 3)

        csv = described_class.to_csv
        expect(csv).to include(CommonIncidentType::EXPORT_COLUMNS.join(','))

        common_incident_types.each do |common_incident_type|
          expect(csv).to include(common_incident_type.formatted_code)
        end
      end
    end
  end
end
