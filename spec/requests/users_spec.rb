require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "#index" do
    let(:path) { "/users" }

    include_examples "unauthenticated", :get

    context "when authenticated" do
      include_examples "unauthorized", :get, :data_classifier
      include_examples "unauthorized", :get, :data_consumer
      include_examples "unauthorized", :get, :data_reviewer
      include_examples "unauthorized", :get, :volunteer
      include_examples "unauthorized", :get, :data_importer

      include_examples "authorized", :get, :data_admin

      context "when authorized" do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        before { sign_in user }

        it "renders the 'index' template" do
          get(path)
          expect(response.body).to include("List of users in the system.")
        end

        it "returns all the data sets" do
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

  describe "#edit" do
    let(:edit_user) { create(:user, role: nil) }
    let(:path) { "/users/#{edit_user.id}/edit" }

    include_examples "unauthenticated", :get

    context "when authenticated" do
      include_examples "unauthorized", :get, :data_classifier
      include_examples "unauthorized", :get, :data_consumer
      include_examples "unauthorized", :get, :data_reviewer
      include_examples "unauthorized", :get, :volunteer
      include_examples "unauthorized", :get, :data_importer

      include_examples "authorized", :get, :data_admin

      context "when authorized" do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        before { sign_in user }

        context "when user == current_user" do
          it "redirects" do
            get "/users/#{user.id}/edit"
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when user != current_user" do
          it "renders the 'edit' template" do
            get "/users/#{edit_user.id}/edit"
            expect(response.body).to include("Make updates to an existing user.")
          end
        end
      end
    end
  end

  describe "#update" do
    let(:update_user) { create(:user, role: nil) }
    let(:path) { "/users/#{update_user.id}" }
    let(:valid_params) do
      {
        user: {
          role_id: create(:role, name: :other).id,
        },
      }
    end

    include_examples "unauthenticated", :patch

    context "when authenticated" do
      include_examples "unauthorized", :patch, :data_classifier
      include_examples "unauthorized", :patch, :data_consumer
      include_examples "unauthorized", :patch, :data_reviewer
      include_examples "unauthorized", :patch, :volunteer

      include_examples "authorized", :patch, :data_admin, :found
      include_examples "authorized", :patch, :data_importer, :found

      context "when authorized" do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        before { sign_in user }

        context "when user == current_user" do
          it "redirects" do
            patch "/users/#{user.id}", params: valid_params
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when user != current_user" do
          context "with invalid params" do
            it "returns an error" do
              patch "/users/#{update_user.id}", params: {
                user: {
                  email: nil,
                },
              }

              expect(response).to have_http_status(:unprocessable_entity)
              expect(response.body).to include("1 error prohibited this user from being saved")
            end
          end

          context "with valid params" do
            it "updates a user" do
              patch "/users/#{update_user.id}", params: valid_params

              expect(response).to have_http_status(:found)
              expect(update_user.reload.role.to_s).to eq("Other")
            end
          end
        end
      end
    end
  end

  describe "#destroy" do
    let(:destroy_user) { create(:user, role: nil) }
    let(:path) { "/users/#{destroy_user.id}" }

    include_examples "unauthenticated", :delete

    context "when authenticated" do
      include_examples "unauthorized", :delete, :data_classifier
      include_examples "unauthorized", :delete, :data_consumer
      include_examples "unauthorized", :delete, :data_reviewer
      include_examples "unauthorized", :delete, :volunteer, :found
      include_examples "unauthorized", :delete, :data_importer, :found

      include_examples "authorized", :delete, :data_admin, :found

      context "when authorized" do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        before { sign_in user }

        context "when user == current_user" do
          it "redirects" do
            delete "/users/#{user.id}"
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when user != current_user" do
          context "with invalid params" do
            it "returns an error" do
              expect do
                delete "/users/123"
              end.to raise_error(ActiveRecord::RecordNotFound)
            end
          end

          context "with valid params" do
            it "destroys the user" do
              delete path

              expect(response).to have_http_status(:found)
              expect(DataSet.count).to eq(0)
            end
          end
        end
      end
    end
  end
end
