require 'resolv'

class ControlGateway < ApplicationRecord
  validates :description, presence: true
  validates :port, presence: true, numericality: { only_integer: true }
  validates :ip_address, :format => { :with => Regexp.union(Resolv::IPv4::Regex, Resolv::IPv6::Regex)

  has_many :control_devices, dependent: :nullify

end
