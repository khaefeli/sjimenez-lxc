Puppet::Type.type(:lxc_interface).provide(:interface) do

  defaultfor :operatingsystem => :ubuntu
  confine :feature => :lxc, :kernel => 'Linux'

  attr_accessor :container, :lxc_version

  def create
    begin
      define_container
      @container.set_config_item("lxc.network.type", @resource[:type])
      @container.set_config_item("lxc.network.name", @resource[:device_name])
      @container.set_config_item("lxc.network.link", @resource[:link]) unless @resource[:link].nil?
      @container.set_config_item("lxc.network.veth.pair", @resource[:veth_name_host]) unless @resource[:veth_name_host].nil?
      @container.set_config_item("lxc.network.vlan_id", @resource[:vlan_id]) unless @resource[:vlan_id].nil?
      @container.set_config_item("lxc.network.macvlan_mode", @resource[:macvlan_mode]) unless @resource[:macvlan_mode].nil?
      @container.set_config_item("lxc.network.ipv4", @resource[:ipv4].flatten) unless @resource[:ipv4].nil?
      @container.set_config_item("lxc.network.hwaddr", @resource[:hwaddr]) unless @resource[:hwaddr].nil?
      @container.set_config_item("lxc.network.flags", @resource[:flags]) unless @resource[:flags].nil?
      @container.save_config
      restart if @resource[:restart]
      true
    rescue LXC::Error
      false
    end
  end

  def exists?
    begin
      define_container
      @container.keys("lxc.network")
      true
    rescue LXC::Error
      false
    end
  end

  def destroy
    begin
      define_container
      @container.clear_config_item("lxc.network")
      @container.save_config
      true
    rescue LXC::Error
      false
    end
  end

  # getters and setters

  def device_name
    begin
      define_container
      @container.config_item("lxc.network.name")
    rescue LXC::Error
      ""
    end
  end

  def device_name=(value)
    begin
      define_container
      @container.clear_config_item("lxc.network.name")
      @container.set_config_item("lxc.network.name",value)
      @container.save_config
      restart if @resource[:restart]
      true
    rescue LXC::Error
      false
    end
  end

  def link
    begin
      define_container
      @container.config_item("lxc.network.link")
    rescue LXC::Error
      # TODO: might be better to fail here instead of returning empty string which
      # would trigger the setter
      ""
    end
  end

  def link=(value)
    begin
      define_container
      @container.clear_config_item("lxc.network.link")
      @container.set_config_item("lxc.network.link",value)
      @container.save_config
      restart if @resource[:restart]
      true
    rescue LXC::Error
      false
    end
  end

  def veth_name_host
    begin
      define_container
      @container.config_item("lxc.network.veth.pair")
    rescue LXC::Error
      # TODO: might be better to fail here instead of returning empty string which
      # would trigger the setter
      ""
    end
  end

  def veth_name_host=(value)
    begin
      define_container
      begin
        @container.clear_config_item("lxc.network.veth.pair")
      rescue LXC::Error
        puts "Warning: clear_config_item for lxc.network.veth.pair failed.\n"
        puts "This might be a bug in lxc_clear_nic only expecting .ipv4 and .ipv6 entries.\n"
        puts "LXC <1.1 is known to be affected. Please make sure nothing else went wrong.\n"
      end
      @container.set_config_item("lxc.network.veth.pair",value)
      @container.save_config
      restart if @resource[:restart]
      true
    rescue LXC::Error
      false
    end
  end

  def vlan_id
    begin
      define_container
      @container.config_item("lxc.network.vlan_id")
    rescue LXC::Error
      # TODO: might be better to fail here instead of returning empty string which
      # would trigger the setter
      ""
    end
  end

  def vlan_id=(value)
    begin
      define_container
      @container.clear_config_item("lxc.network.vlan_id")
      @container.set_config_item("lxc.network.vlan_id",value)
      @container.save_config
      restart if @resource[:restart]
      true
    rescue LXC::Error
      false
    end
  end

  def macvlan_mode
    begin
      define_container
      @container.config_item("lxc.network.macvlan_mode")
    rescue LXC::Error
      # TODO: might be better to fail here instead of returning empty string which
      # would trigger the setter
      ""
    end
  end

  def macvlan_mode=(value)
    begin
      define_container
      @container.clear_config_item("lxc.network.macvlan_mode")
      @container.set_config_item("lxc.network.macvlan_mode",value)
      @container.save_config
      restart if @resource[:restart]
      true
    rescue LXC::Error
      false
    end
  end

  def type
    begin
      define_container
      @container.config_item("lxc.network.type")
    rescue LXC::Error
      # TODO: might be better to fail here instead of returning empty string which
      # would trigger the setter
      ""
    end
  end

  def type=(value)
    begin
      define_container
      @container.clear_config_item("lxc.network.type")
      @container.set_config_item("lxc.network.type",value)
      @container.save_config
      restart if @resource[:restart]
      true
    rescue LXC::Error
      false
    end
  end

  def ipv4
    begin
      # This is a workaround until liblxc is realease with
      # https://github.com/lxc/lxc/pull/332
      # Once liblxc >= 1.1.0, LXC::version can be used to call the proper method
      # hopefull the patch will be there for 1.1.0
      define_container

      unless @lxc_version
        @lxc_version = LXC::version
      end

      if Puppet::Util::Package.versioncmp(@lxc_version,"1.1.0") < 0
        fd = File.new(@container.config_file_name,'r')
        content = fd.readlines
        fd.close
        matched = content.select { |c| c =~ /lxc.network/ }
        index = matched.rindex("lxc.network.name = #{@resource[:device_name]}\n")
        sliced = matched.slice(index..-1)
        # shift first lxc.network.name which should be the one we're handling.
        sliced.shift
        next_block_idx = sliced.index(sliced.grep(/lxc.network.name/).first)
        if next_block_idx.nil?
          ips = sliced
        else
          ips = sliced[0..(next_block_idx - 1)]
        end
        aux = ips.select { |b| b =~ /lxc.network.ipv4 =/ }
        aux.collect { |m| m.split('=').last.strip }
      else
        @container.config_item("lxc.network.ipv4").first
      end
    rescue StandardError
      # TODO: might be better to fail here instead of returning empty string which
      # would trigger the setter
      ""
    end
  end

  def ipv4=(value)
    begin
      define_container
      @container.clear_config_item("lxc.network.ipv4")
      # Why does it get an arrays of arrays?
      @container.set_config_item("lxc.network.ipv4",value.flatten)
      @container.save_config
      restart if @resource[:restart]
      true
    rescue LXC::Error
      false
    end
  end

  def ipv4_gateway
    begin
      define_container
      @container.config_item("lxc.network.ipv4.gateway")
    rescue LXC::Error
      ""
    end
  end

  def ipv4_gateway=(value)
    begin
      define_container
      @container.set_config_item("lxc.network.ipv4.gateway",value)
      @container.save_config
      restart if @resource[:restart]
      true
    rescue LXC::Error
      false
    end
  end

  def hwaddr
    begin
      define_container
      @container.config_item("lxc.network.hwaddr")
    rescue LXC::Error
      # TODO: might be better to fail here instead of returning empty string which
      # would trigger the setter
      ""
    end
  end

  def hwaddr=(value)
    begin
      define_container
      @container.clear_config_item("lxc.network.hwaddr")
      @container.set_config_item("lxc.network.hwaddr",value)
      @container.save_config
      restart if @resource[:restart]
      true
    rescue LXC::Error
      false
    end
  end
  
  def flags
    begin
      define_container
      @container.config_item("lxc.network.flags")
    rescue LXC::Error
      # TODO: might be better to fail here instead of returning empty string which
      # would trigger the setter
      ""
    end
  end

  def flags=(value)
    begin
      define_container
      @container.clear_config_item("lxc.network.flags")
      @container.set_config_item("lxc.network.flags",value)
      @container.save_config
      restart if @resource[:restart]
      true
    rescue LXC::Error
      false
    end
  end

  private
  def define_container
    unless @container
      @container = LXC::Container.new(@resource[:container])
    end
  end

  def restart
    @container.stop
    @container.wait(:stopped, 10)
    @container.start
    @container.wait(:running, 10)
  end
end
