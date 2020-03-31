require "rails_helper"

RSpec.describe Location, :type => :model do
  before(:all) do
    @main_location = build(:location)
    @sub_locations = build_pair(:location)
  end
  
  context "parental hierarchy" do
    it "can create without parent location" do
      main = Post.create!
      comment1 = post.comments.create!(:body => "first comment")
      comment2 = post.comments.create!(:body => "second comment")
      expect(post.reload.comments).to eq([comment2, comment1])
    end
  end
end
