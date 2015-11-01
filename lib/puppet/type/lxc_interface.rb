require 'ipaddr'

Puppet::Type.newtype(:lxc_interface) do
  @doc = 'LXC interface manages network interfaces in a container'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Just a name'
  end

  newparam(:container) do
    desc 'Name of the container'
    newvalues(/\w+/)
  end

  newparam(:index) do
    desc 'Index for interface configuration'
    newvalues(/^0$|^[1-9]+$/)
  end

  newproperty(:device_name) do
    desc 'Device name for the interface in the container'
    newvalues(/\w+/)
  end

  newproperty(:veth_name_host) do
    desc 'Name for the veth pair device on the host'
    newvalues(/\w+/)
  end

  newproperty(:link) do
    desc 'Host interface where to link the container interface'
    newvalues(/\w+/)
  end

  newproperty(:vlan_id) do
    desc 'VLAN ID to use with network type is vlan'
    newvalues(/\d+/)
  end

  newproperty(:macvlan_mode) do
    desc 'macvlan mode'
    validate do |value|
      unless ['private','vepa','bridge'].include?value
        raise ArgumentError, 'Invalid macvlan mode'
      end
    end
  end

  newproperty(:type) do
    desc 'Network type'
    defaultto 'veth'
    validate do |value|
      unless ['veth', 'vlan', 'macvlan', 'phys'].include?value
        raise ArgumentError, 'Invalid network type'
      end

      raise ArgumentError, 'Missing VLAN ID' if @resource[:vlan_id].nil? and value == 'vlan'
      raise ArgumentError, 'Missing link, needed for macvlan' if @resource[:link].nil? and value == 'macvlan'
      raise ArgumentError, 'Missing macvlan_mode' if @resource[:macvlan_mode].nil? and value == 'macvlan'
    end
  end

  newproperty(:ipv4, :array_matching => :all) do
    desc 'IPv4 address'
    validate do |value|
      ips = Array.new

      case value.class.to_s
      when 'String'
        ips << value
      when 'Array'
        ips = value
      else
        raise ArgumentError, 'ipv4 parameter must be either String or Array'
      end

      ips.each do |ip|
        begin
          raise ArgumentError, 'Invalid IPv4 address' unless IPAddr.new(ip).ipv4?
        end
      end
    end
    munge do |value|
      if value.kind_of?String
        Array.new.push(value)
      else
        value
      end
    end
    # Is it really needed?
    def insync?(is)
      self.devfail "#{self.class.name}'s should is not array" unless @should.is_a?(Array)
      return true if @should.empty?
      return (is == @should.flatten or is == @should.collect { |v| v.to_s }) if match_all?
      @should.each { |val| return true if is == val or is == val.to_s }
      false
    end
  end

  newproperty(:ipv6, :array_matching => :all) do
    desc 'IPv6 address'
    validate do |value|
      ips = Array.new

      case value.class.to_s
      when 'String'
        ips << value
      when 'Array'
        ips = value
      else
        raise ArgumentError, 'ipv6 parameter must be either String or Array'
      end

      ips.each do |ip|
        begin
          raise ArgumentError, 'Invalid IPv6 address' unless IPAddr.new(ip).ipv6?
        end
      end
    end
    munge do |value|
      if value.kind_of?String
        Array.new.push(value)
      else
        value
      end
    end
    # Is it really needed?
    def insync?(is)
      self.devfail "#{self.class.name}'s should is not array" unless @should.is_a?(Array)
      return true if @should.empty?
      return (is == @should.flatten or is == @should.collect { |v| v.to_s }) if match_all?
      @should.each { |val| return true if is == val or is == val.to_s }
      false
    end
  end

  newproperty(:ipv4_gateway) do
    desc 'Gateway IPv4 address'
    validate do |value|
      begin
        IPAddr.new(value)
      rescue ArgumentError
        raise ArgumentError, 'Invalid gateway IPv4 address'
      end
    end
  end

  newproperty(:ipv6_gateway) do
    desc 'Gateway IPv6 address'
    validate do |value|
      begin
        IPAddr.new(value)
      rescue ArgumentError
        raise ArgumentError, 'Invalid gateway IPv6 address'
      end
    end
  end

  newproperty(:hwaddr) do
    desc 'MAC address for the interface'
    newvalues(/^([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}$/i)
  end

  newparam(:restart) do
    defaultto false
    newvalues(:true,:false)
  end

  autorequire(:lxc) do
    [self[:container]]
  end

  validate do
    raise ArgumentError, 'Index parameter is required' if self[:index].nil?
    raise ArgumentError, 'Container parameter is required' if self[:container].nil?
    raise ArgumentError, 'device_name parameter is required' if self[:device_name].nil?
  end
end
