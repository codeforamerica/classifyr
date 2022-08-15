RSpec.shared_examples "papertrail versioning" do |model, field|
  describe "versioning" do
    it "has versioning enabled on create" do
      record = create(model)

      expect do
        record.update(field => 1)
      end.to change { record.versions.count }.by(1)

      expect(record.versions.last.object_changes).to include(field)
    end
  end
end
