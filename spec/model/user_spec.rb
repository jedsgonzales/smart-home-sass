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

  context "Standard User Rights" do
    it "cannot perform all sorts of rights" do
      UserAcl::ACL.each do |perm_act, mask_shift|
        UserAcl::BASE_ACL.each do |perm_scope, perm_sections|
          perm_sections.each do |perm_section, perm_bits|
            expect( @user.send("can_#{perm_act}_#{perm_scope}_#{perm_section}?") ).to be false
          end
        end
      end
    end
  end

  context "Admin Rights" do
    it "can perform all sorts of rights" do
      UserAcl::ACL.each do |perm_act, mask_shift|
        UserAcl::BASE_ACL.each do |perm_scope, perm_sections|
          perm_sections.each do |perm_section, perm_bits|
            expect( @admin.send("can_#{perm_act}_#{perm_scope}_#{perm_section}?") ).to be true
          end
        end
      end
    end
  end


end
