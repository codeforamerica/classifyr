# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CallTypes' do
  let(:user) { create(:user) }
  let(:data_set) { create(:data_set) }
  let(:common_incident_type) { create(:common_incident_type) }
  let!(:field) { create(:field, data_set:, common_type: Classification::CALL_TYPE) }
  let!(:unique_value) { create(:unique_value, field:) }

  describe '#index' do
    let(:path) { "/classifications/call_types/data_sets/#{data_set.slug}/classify" }

    include_examples 'unauthenticated', :get

    context 'when authenticated' do
      include_examples 'unauthorized', :get, :data_consumer
      include_examples 'unauthorized', :get, :data_reviewer
      include_examples 'unauthorized', :get, :volunteer
      include_examples 'unauthorized', :get, :data_importer

      include_examples 'authorized', :get, :data_admin, :found
      include_examples 'authorized', :get, :data_classifier, :found

      context 'when authorized' do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        before { sign_in user }

        it 'shows the classification page' do
          get(path)

          expect(response.body).to include(data_set.title)
          expect(response.body).to include(unique_value.value)
        end
      end
    end
  end

  describe '#show' do
    let(:path) { "/classifications/call_types/#{unique_value.slug}" }

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

        before { sign_in user }

        it 'shows the classification page' do
          get(path)

          expect(response.body).to include(data_set.title)
          expect(response.body).to include(unique_value.value)
        end
      end
    end
  end

  describe '#create' do
    let(:path) { "/classifications/call_types/#{unique_value.slug}" }
    let(:valid_params) do
      {
        classification: {
          unique_value_id: unique_value.id,
          common_type: Classification::CALL_TYPE,
          value: unique_value.value,
          common_incident_type_id: common_incident_type.id
        }
      }
    end

    include_examples 'unauthenticated', :post

    context 'when authenticated' do
      include_examples 'unauthorized', :post, :data_consumer
      include_examples 'unauthorized', :post, :data_reviewer
      include_examples 'unauthorized', :post, :volunteer
      include_examples 'unauthorized', :post, :data_importer

      include_examples 'authorized', :post, :data_admin
      include_examples 'authorized', :post, :data_classifier

      context 'when authorized' do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        before { sign_in user }

        context 'with invalid params' do
          it 'returns an error' do
            post path, params: {
              classification: {
                value: unique_value.value
              }
            }

            expect(Classification.count).to eq(0)
            expect(response.body).to include('Something went wrong')
          end
        end

        context 'with valid params' do
          it 'creates a classification' do
            post path, params: valid_params

            expect(response).to have_http_status(:ok)
            expect(Classification.count).to eq(1)
            expect(Classification.last.value).to eq(unique_value.value)
          end
        end
      end
    end
  end
end
