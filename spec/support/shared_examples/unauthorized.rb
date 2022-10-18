# frozen_string_literal: true

RSpec.shared_examples 'unauthorized' do |method, role|
  context 'when unauthorized' do
    it 'redirects to the dashboard' do
      role = create(:role, name: role)
      user = create(:user, role:)
      sign_in user

      # path must be defined in a let in the parent spec
      send(method, path)

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(dashboards_path)
    end
  end
end
