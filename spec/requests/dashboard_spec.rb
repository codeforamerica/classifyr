require "rails_helper"

RSpec.describe "Dashboards", type: :request do
  describe "#index" do
    let(:path) { "/dashboards" }

    include_examples "unauthenticated", :get

    context "when authenticated" do
      include_examples "authorized", :get, :data_admin, :found
      include_examples "authorized", :get, :volunteer, :found
      include_examples "authorized", :get, :data_importer, :found
      include_examples "authorized", :get, :data_classifier, :found
      include_examples "authorized", :get, :data_consumer, :found
      include_examples "authorized", :get, :data_reviewer, :found

      context "when authorized" do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        before { sign_in user }

        it "redirects to the classification page" do
          get(path)
          expect(response.body).to include(
            "You are being <a href=\"http://www.example.com/classifications/call_types\">redirected</a>",
          )
        end
      end
    end
  end

  describe "navigation menu" do
    context "when unauthorized" do
      let(:role) { create(:role, name: :volunteer) }
      let(:user) { create(:user, role:) }

      before { sign_in user }

      it "does not include the 'Users' menu item" do
        get(path)
        html = Nokogiri::HTML(response.body.to_s)
        users_link = html.css('//a[@href="/users"]')
        expect(users_link.length).to eq(0)
      end
    end

    context "when authorized" do
      let(:role) { create(:role, name: :data_admin) }
      let(:user) { create(:user, role:) }

      before { sign_in user }

      it "does not include the 'Users' menu item" do
        get(path)
        get(response.headers["Location"])

        html = Nokogiri::HTML(response.body.to_s)
        users_link = html.css('//a[@href="/admin/users"]')
        expect(users_link.length).to eq(1)
      end
    end
  end
end
