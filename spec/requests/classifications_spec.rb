require "rails_helper"

RSpec.describe "Classifications", type: :request do
  let(:user) { create(:user) }

  describe "#index" do
    let(:path) { "/classifications" }

    include_examples "unauthenticated", :get

    context "when authenticated" do
      include_examples "authorized", :get, :data_consumer, :found
      include_examples "authorized", :get, :data_reviewer, :found
      include_examples "authorized", :get, :volunteer, :found
      include_examples "authorized", :get, :data_importer, :found
      include_examples "authorized", :get, :data_admin, :found
      include_examples "authorized", :get, :data_classifier, :found

      context "when authorized" do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        before { sign_in user }

        it "redirects to the call_types action" do
          get(path)
          expect(get(path)).to redirect_to(call_types_classifications_path)
        end
      end
    end
  end

  describe "#call_types" do
    let(:path) { "/classifications/call_types" }

    include_examples "unauthenticated", :get

    context "when authenticated" do
      include_examples "authorized", :get, :data_consumer
      include_examples "authorized", :get, :data_reviewer
      include_examples "authorized", :get, :volunteer
      include_examples "authorized", :get, :data_importer
      include_examples "authorized", :get, :data_admin
      include_examples "authorized", :get, :data_classifier

      context "when authorized" do
        let(:role) { create(:role, name: :data_admin) }
        let(:user) { create(:user, role:) }

        before { sign_in user }

        it "lists data sets in the expected order" do
          data_set = create(:data_set)
          create(:field, data_set:, common_type: Classification::CALL_TYPE)

          get(path)
          html = Nokogiri::HTML(response.body)
          data_set_titles = html.css(".data-set-title")
          expect(data_set_titles.count).to eq(1)
          expect(data_set_titles.children.first.to_s).to eq(data_set.title)
        end
      end
    end
  end
end
