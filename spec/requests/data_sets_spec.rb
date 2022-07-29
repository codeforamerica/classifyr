require "rails_helper"

RSpec.describe "DataSets", type: :request do
  let(:user) { create(:user) }
  let(:data_set) { create(:data_set) }

  describe "#index" do
    context "when unauthenticated" do
      it "redirects to the login page" do
        get "/data_sets"
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when authenticated" do
      before { sign_in user }

      it "returns 200 OK" do
        get "/data_sets"
        expect(response).to have_http_status(:ok)
      end

      it "renders the 'index' template" do
        get "/data_sets"
        expect(response.body).to include("<h3>Datasets</h3>")
      end

      it "returns all the data sets" do
        data_sets = create_list(:data_set, 3)
        get "/data_sets"
        data_sets.each do |data_set|
          expect(response.body).to include(data_set.title)
        end
      end
    end
  end

  describe "#show" do
    context "when unauthenticated" do
      it "redirects to the login page" do
        get "/data_sets/#{data_set.id}"
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when authenticated" do
      before { sign_in user }

      it "returns 200 OK" do
        get "/data_sets/#{data_set.id}"
        expect(response).to have_http_status(:ok)
      end

      it "renders the 'show' template" do
        get "/data_sets/#{data_set.id}"
        expect(response.body).to include(data_set.title)
      end
    end
  end

  describe "#new" do
    context "when unauthenticated" do
      it "redirects to the login page" do
        get "/data_sets/new"
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when authenticated" do
      before { sign_in user }

      it "returns 200 OK" do
        get "/data_sets/new"
        expect(response).to have_http_status(:ok)
      end

      it "renders the 'new' template" do
        get "/data_sets/new"
        expect(response.body).to include("New Dataset")
      end
    end
  end

  describe "#edit" do
    context "when unauthenticated" do
      it "redirects to the login page" do
        get "/data_sets/#{data_set.id}/edit"
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when authenticated" do
      before { sign_in user }

      it "returns 200 OK" do
        get "/data_sets/#{data_set.id}/edit"
        expect(response).to have_http_status(:ok)
      end

      it "renders the 'edit' template" do
        get "/data_sets/#{data_set.id}/edit"
        expect(response.body).to include("Make updates to this existing dataset.")
      end
    end
  end

  describe "#create" do
    context "when unauthenticated" do
      it "redirects to the login page" do
        post "/data_sets", params: {}
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when authenticated" do
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
          post "/data_sets", params: {
            data_set: {
              title: "My Dataset",
              files: [
                Rack::Test::UploadedFile.new("spec/support/files/police-incidents-2022.csv", "text/csv"),
              ],
            },
          }

          expect(response).to have_http_status(:found)
          expect(DataSet.count).to eq(1)
          expect(DataSet.last.title).to eq("My Dataset")
        end
      end
    end
  end

  describe "#update" do
    context "when unauthenticated" do
      it "redirects to the login page" do
        patch "/data_sets/#{data_set.id}", params: {}
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when authenticated" do
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
          patch "/data_sets/#{data_set.id}", params: {
            data_set: {
              title: "My Updated Dataset",
            },
          }

          expect(response).to have_http_status(:found)
          expect(data_set.reload.title).to eq("My Updated Dataset")
        end
      end
    end
  end

  describe "#destroy" do
    context "when unauthenticated" do
      it "redirects to the login page" do
        delete "/data_sets/#{data_set.id}", params: {}
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when authenticated" do
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
          delete "/data_sets/#{data_set.id}"

          expect(response).to have_http_status(:found)
          expect(DataSet.count).to eq(0)
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

    context "when unauthenticated" do
      it "redirects to the login page" do
        get "/data_sets/#{data_set.id}/map"
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when authenticated" do
      before { sign_in user }

      it "maps the dataset" do
        expect_any_instance_of(DataSet).to receive(:prepare_datamap)
        get "/data_sets/#{data_set.id}/map"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Map Data Fields")
      end
    end
  end

  describe "#analyze" do
    let(:data_set) {
      create(:data_set, files: [
               Rack::Test::UploadedFile.new("spec/support/files/police-incidents-2022.csv", "text/csv"),
             ])
    }

    context "when unauthenticated" do
      it "redirects to the login page" do
        get "/data_sets/#{data_set.id}/analyze"
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when authenticated" do
      before { sign_in user }

      it "analyses the dataset" do
        get "/data_sets/#{data_set.id}/analyze"

        expect(response).to have_http_status(:ok)
        expect(data_set.reload.analyzed?).to be(true)
      end
    end
  end
end
