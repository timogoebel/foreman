module Net::DHCP
  class DHCP6Record < Net::DHCP::Record
    attr_accessor :ip6

    def initialize(opts = { })
      super
      self.network = Net::Validations.validate_ip6! self.network
      self.ip6 = Net::Validations.validate_ip6! self.ip6
    end

    def to_s
      "#{hostname}-#{mac}/#{ip6}"
    end

    def self.human
      N_('DHCPv6')
    end
  end
end
