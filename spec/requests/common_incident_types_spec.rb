# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CommonIncidentTypes' do
  let(:user) { create(:user) }

  describe '#search' do
    let(:path) { '/common_incident_types/search' }

    include_examples 'unauthenticated', :get

    context 'when authenticated' do
      include_examples 'unauthorized', :get, :data_consumer
      include_examples 'unauthorized', :get, :data_reviewer
      include_examples 'unauthorized', :get, :volunteer
      include_examples 'unauthorized', :get, :data_importer

      include_examples 'authorized', :get, :data_admin
      include_examples 'authorized', :get, :data_classifier

      context 'when authorized' do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        let!(:h911) { create(:common_incident_type, code: '911H', description: '911 HANG UP', notes: '') }
        let!(:alrgas) { create(:common_incident_type, code: 'ALRGAS', description: 'FIRE ALARM - GAS', notes: '') }
        let!(:bio) { create(:common_incident_type, code: 'BIO', description: 'BIOLOGICAL THREAT', notes: '') }
        let!(:baricade) do
          create(:common_incident_type, code: 'BARICADE', description: 'BARRICADED',
                                        notes: 'Barricaded person, gunman etc')
        end

        before { sign_in user }

        context 'without a query' do
          it 'returns nothing' do
            get(path)

            html = Nokogiri::HTML(response.body)
            incident_cards = html.css('[data-incident-id]')

            expect(incident_cards).to be_blank
          end
        end

        context 'with a query' do
          it 'returns matching results' do
            get("#{path}?q=b")

            html = Nokogiri::HTML(response.body)

            card = html.css("[data-incident-id=#{h911.id}]")
            expect(card).to be_blank

            card = html.css("[data-incident-id=#{alrgas.id}]")
            expect(card).to be_blank

            card = html.css("[data-incident-id=#{bio.id}]")
            expect(card).not_to be_blank

            card = html.css("[data-incident-id=#{baricade.id}]")
            expect(card).not_to be_blank
          end
        end
      end
    end
  end
end
