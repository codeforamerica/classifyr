RSpec.shared_examples "authorized" do |method, role, status|
  context "when authorized" do
    it "returns 200" do
      role = create(:role, name: role)
      user = create(:user, role:)
      sign_in user

      # path and valid_params must be defined in a let in the parent spec
      if [:post, :patch].include?(method)
        send(method, path, params: valid_params)
      else
        send(method, path)
      end

      expect(response).to have_http_status(status || :ok)
    end
  end
end
