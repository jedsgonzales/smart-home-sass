require "rails_helper"

RSpec.describe User, :type => :model do
  before(:all) do
    @admin = build(:admin_user)
    @user = build(:user)
  end

  context "ACL Module" do
    it "can respond to acl methods" do
      expect( @admin.respond_to?(:can_view_other_users?) ).to be true
    end

    it "can respond to generic acl method" do
      expect( @admin.respond_to?(:can?) ).to be true
    end
  end
end
