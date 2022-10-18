# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Users', type: :request do
  describe '#index' do
    let(:path) { '/admin/users' }

    include_examples 'unauthenticated', :get

    context 'when authenticated' do
      include_examples 'unauthorized', :get, :data_classifier
      include_examples 'unauthorized', :get, :data_consumer
      include_examples 'unauthorized', :get, :data_reviewer
      include_examples 'unauthorized', :get, :volunteer
      include_examples 'unauthorized', :get, :data_importer

      include_examples 'authorized', :get, :data_admin

      context 'when authorized' do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        before { sign_in user }

        it "renders the 'index' template" do
          get(path)
          expect(response.body).to include('List of users in the system.')
        end

        it 'returns all the data sets' do
          role = create(:role, name: :volunteer)
          users = create_list(:user, 3, role:)
          get(path)
          users.each do |user|
            expect(response.body).to include(user.email)
          end
        end
      end
    end
  end

  describe '#edit' do
    let(:edit_user) { create(:user, role: nil) }
    let(:path) { "/admin/users/#{edit_user.slug}/edit" }

    include_examples 'unauthenticated', :get

    context 'when authenticated' do
      include_examples 'unauthorized', :get, :data_classifier
      include_examples 'unauthorized', :get, :data_consumer
      include_examples 'unauthorized', :get, :data_reviewer
      include_examples 'unauthorized', :get, :volunteer
      include_examples 'unauthorized', :get, :data_importer

      include_examples 'authorized', :get, :data_admin

      context 'when authorized' do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        before { sign_in user }

        context 'when user == current_user' do
          it 'redirects' do
            get "/admin/users/#{user.slug}/edit"
            expect(response).to have_http_status(:redirect)
          end
        end

        context 'when user != current_user' do
          it "renders the 'edit' template" do
            get "/admin/users/#{edit_user.slug}/edit"
            expect(response.body).to include('Make updates to an existing user.')
          end
        end
      end
    end
  end

  describe '#update' do
    let(:update_user) { create(:user, role: nil) }
    let(:path) { "/admin/users/#{update_user.slug}" }
    let(:valid_params) do
      {
        user: {
          role_id: create(:role, name: :other).id
        }
      }
    end

    include_examples 'unauthenticated', :patch

    context 'when authenticated' do
      include_examples 'unauthorized', :patch, :data_classifier
      include_examples 'unauthorized', :patch, :data_consumer
      include_examples 'unauthorized', :patch, :data_reviewer
      include_examples 'unauthorized', :patch, :volunteer
      include_examples 'unauthorized', :patch, :data_importer, :found

      include_examples 'authorized', :patch, :data_admin, :found

      context 'when authorized' do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        before { sign_in user }

        context 'when user == current_user' do
          it 'redirects' do
            patch "/admin/users/#{user.slug}", params: valid_params
            expect(response).to have_http_status(:redirect)
          end
        end

        context 'when user != current_user' do
          context 'with invalid params' do
            it 'returns an error' do
              patch "/admin/users/#{update_user.slug}", params: {
                user: {
                  email: nil
                }
              }

              expect(response).to have_http_status(:unprocessable_entity)
              expect(response.body).to include('Email can&#39;t be blank')
            end
          end

          context 'with valid params' do
            it 'updates a user' do
              patch "/admin/users/#{update_user.slug}", params: valid_params

              expect(response).to have_http_status(:found)
              expect(update_user.reload.role.to_s).to eq('Other')
            end
          end
        end
      end
    end
  end

  describe '#destroy' do
    let(:destroy_user) { create(:user, role: nil) }
    let(:path) { "/admin/users/#{destroy_user.slug}" }

    include_examples 'unauthenticated', :delete

    context 'when authenticated' do
      include_examples 'unauthorized', :delete, :data_classifier
      include_examples 'unauthorized', :delete, :data_consumer
      include_examples 'unauthorized', :delete, :data_reviewer
      include_examples 'unauthorized', :delete, :volunteer, :found
      include_examples 'unauthorized', :delete, :data_importer, :found

      include_examples 'authorized', :delete, :data_admin, :found

      context 'when authorized' do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        before { sign_in user }

        context 'when user == current_user' do
          it 'redirects' do
            delete "/admin/users/#{user.slug}"
            expect(response).to have_http_status(:redirect)
            expect(User.find_by(id: user.id)).not_to be_nil
          end
        end

        context 'when user != current_user' do
          context 'with invalid params' do
            it 'returns an error' do
              expect do
                delete '/admin/users/123'
              end.to raise_error(ActiveRecord::RecordNotFound)
            end
          end

          context 'with valid params' do
            it 'destroys the user' do
              delete path

              expect(response).to have_http_status(:found)
              expect(User.find_by(id: user.id)).not_to be_nil
              expect(User.find_by(id: destroy_user.id)).to be_nil
            end
          end
        end
      end
    end
  end
end
