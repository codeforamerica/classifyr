require "rails_helper"

RSpec.describe "Dashboards", type: :request do
  describe "#index" do
    let(:path) { "/dashboards" }

    include_examples "unauthenticated", :get

    context "when authenticated" do
      include_examples "authorized", :get, :data_admin
      include_examples "authorized", :get, :volunteer
      include_examples "authorized", :get, :data_importer
      include_examples "authorized", :get, :data_classifier
      include_examples "authorized", :get, :data_consumer
      include_examples "authorized", :get, :data_reviewer

      context "when authorized" do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        before { sign_in user }

        it "renders the 'index' template" do
          get(path)
          expect(response.body).to include("Dashboards")
        end
      end
    end
  end
end
