require "rails_helper"

RSpec.describe "DataSets", type: :request do
  let(:user) { create(:user) }

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
end
