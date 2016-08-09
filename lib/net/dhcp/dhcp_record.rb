module Net::DHCP
  class DHCPRecord < Net::DHCP::Record
    attr_accessor :ip

    def initialize(opts = { })
      super
      self.network = Net::Validations.validate_network! self.network
      self.ip = Net::Validations.validate_ip! self.ip
    end

    def to_s
      "#{hostname}-#{mac}/#{ip}"
    end

    def self.human
      'DHCP'
    end
  end
end
