require "rails_helper"

RSpec.describe Location, :type => :model do
  before(:all) do
    @main_location = build(:location)
    @sub_location = build(:location)
  end

  context "parental hierarchy" do
    it "can create without parent location" do
      @main_location.valid?
      expect( @main_location.errors.empty? ).to be true
    end

    it "can create with sub locations" do
      @sub_location.parent = @main_location
      @sub_location.valid?
      expect( @sub_location.errors.empty? ).to be true
      expect( @sub_location.parent_location ).to equal(  @main_location.id )
    end

    it "parent location to sub locations saves properly" do
      @sub_location.parent = @main_location

      @main_location.save
      @sub_location.save
      
      expect( @sub_location.parent_location ).to equal(  @main_location.id )
    end
  end
end
