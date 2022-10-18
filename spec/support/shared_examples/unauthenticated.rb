# frozen_string_literal: true

RSpec.shared_examples 'unauthenticated' do |method|
  context 'when unauthenticated' do
    it 'redirects to the log in page' do
      # path must be defined in a let in the parent spec
      send(method, path)

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
