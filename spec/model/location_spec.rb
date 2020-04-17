require "rails_helper"

RSpec.describe Location, :type => :model do
  before(:all) do
    @main_location = build(:location)
    @sub_location = build(:location)

    @main_location2 = build(:location)
    @sub_location2 = build(:location)
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
      @main_location2.sub_locations << @sub_location2

      @main_location2.save
      @sub_location2.save

      expect( @sub_location2.errors.empty? ).to be true
      expect( @sub_location2.parent_location ).to equal(  @main_location2.id )

      @main_location2.destroy
      expect( Location.exists?(@sub_location2.id) ).to be false
    end

    it "destroys sub locations when deleted" do
      @main_location2.destroy
      expect( Location.exists?(@sub_location2.id) ).to be false
    end

  end
end
