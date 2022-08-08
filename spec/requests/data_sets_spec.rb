require "rails_helper"

RSpec.describe "DataSets", type: :request do
  let(:user) { create(:user) }
  let(:data_set) { create(:data_set) }

  describe "#index" do
    let(:path) { "/data_sets" }

    include_examples "unauthenticated", :get

    context "when authenticated" do
      include_examples "unauthorized", :get, :data_classifier
      include_examples "unauthorized", :get, :data_consumer
      include_examples "unauthorized", :get, :data_reviewer

      include_examples "authorized", :get, :data_admin
      include_examples "authorized", :get, :volunteer
      include_examples "authorized", :get, :data_importer

      context "when authorized" do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        before { sign_in user }

        it "renders the 'index' template" do
          get(path)
          expect(response.body).to include("<h3>Datasets</h3>")
        end

        it "returns all the data sets" do
          data_sets = create_list(:data_set, 3)
          get(path)
          data_sets.each do |data_set|
            expect(response.body).to include(data_set.title)
          end
        end
      end
    end
  end

  describe "#show" do
    let(:path) { "/data_sets/#{data_set.id}" }

    include_examples "unauthenticated", :get

    context "when authenticated" do
      include_examples "unauthorized", :get, :data_classifier
      include_examples "unauthorized", :get, :data_consumer
      include_examples "unauthorized", :get, :data_reviewer

      include_examples "authorized", :get, :data_admin
      include_examples "authorized", :get, :volunteer
      include_examples "authorized", :get, :data_importer

      context "when authorized" do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        before { sign_in user }

        it "renders the 'show' template" do
          get path
          expect(response.body).to include(data_set.title)
        end
      end
    end
  end

  describe "#new" do
    let(:path) { "/data_sets/new" }

    include_examples "unauthenticated", :get

    context "when authenticated" do
      include_examples "unauthorized", :get, :data_classifier
      include_examples "unauthorized", :get, :data_consumer
      include_examples "unauthorized", :get, :data_reviewer
      include_examples "unauthorized", :get, :volunteer

      include_examples "authorized", :get, :data_admin
      include_examples "authorized", :get, :data_importer

      context "when authorized" do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        before { sign_in user }

        it "renders the 'new' template" do
          get path
          expect(response.body).to include("New Dataset")
        end
      end
    end
  end

  describe "#edit" do
    let(:path) { "/data_sets/#{data_set.id}/edit" }

    include_examples "unauthenticated", :get

    context "when authenticated" do
      include_examples "unauthorized", :get, :data_classifier
      include_examples "unauthorized", :get, :data_consumer
      include_examples "unauthorized", :get, :data_reviewer
      include_examples "unauthorized", :get, :volunteer

      include_examples "authorized", :get, :data_admin
      include_examples "authorized", :get, :data_importer

      context "when authorized" do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        before { sign_in user }

        it "renders the 'edit' template" do
          get "/data_sets/#{data_set.id}/edit"
          expect(response.body).to include("Make updates to this existing dataset.")
        end
      end
    end
  end

  describe "#create" do
    let(:path) { "/data_sets" }
    let(:valid_params) do
      {
        data_set: {
          title: "My Dataset",
          files: [
            Rack::Test::UploadedFile.new("spec/support/files/police-incidents-2022.csv", "text/csv"),
          ],
        },
      }
    end

    include_examples "unauthenticated", :post

    context "when authenticated" do
      include_examples "unauthorized", :post, :data_classifier
      include_examples "unauthorized", :post, :data_consumer
      include_examples "unauthorized", :post, :data_reviewer
      include_examples "unauthorized", :post, :volunteer

      include_examples "authorized", :post, :data_admin, :found
      include_examples "authorized", :post, :data_importer, :found

      context "when authorized" do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        before { sign_in user }

        context "with invalid params" do
          it "returns an error" do
            post "/data_sets", params: {
              data_set: {
                title: "My Dataset",
                files: [],
              },
            }

            expect(response).to have_http_status(:unprocessable_entity)
            expect(DataSet.count).to eq(0)
            expect(response.body).to include("1 error prohibited this data_set from being saved")
          end
        end

        context "with valid params" do
          it "creates a dataset" do
            post "/data_sets", params: valid_params

            expect(response).to have_http_status(:found)
            expect(DataSet.count).to eq(1)
            expect(DataSet.last.title).to eq("My Dataset")
          end
        end
      end
    end
  end

  describe "#update" do
    let(:path) { "/data_sets/#{data_set.id}" }
    let(:valid_params) do
      {
        data_set: {
          title: "My Updated Dataset",
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

        context "with invalid params" do
          it "returns an error" do
            patch "/data_sets/#{data_set.id}", params: {
              data_set: {
                title: nil,
              },
            }

            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.body).to include("1 error prohibited this data_set from being saved")
          end
        end

        context "with valid params" do
          it "updates a dataset" do
            patch "/data_sets/#{data_set.id}", params: valid_params

            expect(response).to have_http_status(:found)
            expect(data_set.reload.title).to eq("My Updated Dataset")
          end
        end
      end
    end
  end

  describe "#destroy" do
    let(:path) { "/data_sets/#{data_set.id}" }

    include_examples "unauthenticated", :delete

    context "when authenticated" do
      include_examples "unauthorized", :delete, :data_classifier
      include_examples "unauthorized", :delete, :data_consumer
      include_examples "unauthorized", :delete, :data_reviewer
      include_examples "unauthorized", :delete, :volunteer

      include_examples "authorized", :delete, :data_admin, :found
      include_examples "authorized", :delete, :data_importer, :found

      context "when authorized" do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        before { sign_in user }

        context "with invalid params" do
          it "returns an error" do
            expect {
              delete "/data_sets/123"
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end

        context "with valid params" do
          it "destroys the dataset" do
            delete path

            expect(response).to have_http_status(:found)
            expect(DataSet.count).to eq(0)
          end
        end
      end
    end
  end

  describe "#map" do
    let(:data_set) {
      create(:data_set, files: [
               Rack::Test::UploadedFile.new("spec/support/files/police-incidents-2022.csv", "text/csv"),
             ])
    }

    let(:path) { "/data_sets/#{data_set.id}/map" }

    include_examples "unauthenticated", :get

    context "when authenticated" do
      include_examples "unauthorized", :get, :data_classifier
      include_examples "unauthorized", :get, :data_consumer
      include_examples "unauthorized", :get, :data_reviewer
      include_examples "unauthorized", :get, :volunteer

      include_examples "authorized", :get, :data_admin
      include_examples "authorized", :get, :data_importer

      context "when authorized" do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        before { sign_in user }

        it "maps the dataset" do
          expect_any_instance_of(DataSet).to receive(:prepare_datamap)
          get path

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("Map Data Fields")
        end
      end
    end
  end

  describe "#analyze" do
    let(:data_set) {
      create(:data_set, files: [
               Rack::Test::UploadedFile.new("spec/support/files/police-incidents-2022.csv", "text/csv"),
             ])
    }

    let(:path) { "/data_sets/#{data_set.id}/analyze" }

    include_examples "unauthenticated", :get

    context "when authenticated" do
      include_examples "unauthorized", :get, :data_classifier
      include_examples "unauthorized", :get, :data_consumer
      include_examples "unauthorized", :get, :data_reviewer
      include_examples "unauthorized", :get, :volunteer

      include_examples "authorized", :get, :data_admin
      include_examples "authorized", :get, :data_importer

      context "when authorized" do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        before { sign_in user }

        it "analyses the dataset" do
          get "/data_sets/#{data_set.id}/analyze"

          expect(response).to have_http_status(:ok)
          expect(data_set.reload.analyzed?).to be(true)
        end
      end
    end
  end
end
