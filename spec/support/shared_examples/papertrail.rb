# frozen_string_literal: true

RSpec.shared_examples 'papertrail versioning' do |model, field, trait: nil|
  describe 'versioning' do
    it 'has versioning enabled on create' do
      record = create(model, trait)

      expect do
        record.update(field => 1)
      end.to change { record.versions.count }.by(1)

      expect(record.versions.last.object_changes).to include(field)
    end
  end
end
