RSpec.shared_examples "associations" do |model, associations|
  describe "associations" do
    it "has the given associations" do
      associations.each do |association|
        expect(build(model)).to respond_to(association)
      end
    end
  end
end
