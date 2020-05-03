require "rails_helper"

RSpec.describe ControlDeviceProfile, :type => :model do
  before(:all) do
    @device1 = build(:control_device_profile)
    @device2 = build(:smart_g4_device)
  end

end
