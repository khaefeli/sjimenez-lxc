
Puppet::Type.type(:lxc_interface).provide(:interface) do
  desc "set the network interfaces for a container managed by the lxc provider"

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
      @container.set_config_item("lxc.network.ipv4.gateway", @resource[:ipv4_gateway]) unless @resource[:ipv4_gateway].nil?
      @container.set_config_item("lxc.network.hwaddr", @resource[:hwaddr]) unless @resource[:hwaddr].nil?
      @container.set_config_item("lxc.network.flags", @resource[:flags]) unless @resource[:flags].nil?
      @container.save_config
      restart if @resource[:restart]
      true
    rescue LXC::Error => e
      fail("Failed to add #{@resource[:name]}: #{e.message}")
      false
    end
  end

  def exists?
    begin
      define_container
      devicename = @container.config_item("lxc.network.name")
      if devicename.to_s.empty?
        false #return false to start interface creation (see def create) 
      else
        true #the interface exists. trigger the getter and setters for the resource params
      end
    rescue LXC::Error => e
      fail("Failed to check if interface exists name: #{e.message}")
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
    rescue LXC::Error => e
      fail("Failed to get device_name: #{e.message}")
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
    rescue LXC::Error => e
      fail("Failed to set device_name: #{e.message}")
    end
  end

  def link
    begin
      define_container
      @container.config_item("lxc.network.link")
    rescue LXC::Error => e
      fail("Failed to get link: #{e.message}")
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
    rescue LXC::Error => e
      fail("Failed to set link: #{e.message}")
    end
  end

  def veth_name_host
    begin
      define_container
      @container.config_item("lxc.network.veth.pair")
    rescue LXC::Error => e
      fail("Failed to get veth.pair: #{e.message}")
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
      @container.set_config_item("lxc.networt.veth.pair",value)
      @container.save_config
      restart if @resource[:restart]
      true
    rescue LXC::Error => e
      fail("Failed to set veth.pair: #{e.message}")
    end
  end

  def vlan_id
    begin
      define_container
      @container.config_item("lxc.network.vlan_id")
    rescue LXC::Error => e
      fail("Failed to get vlan.id: #{e.message}")
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
    rescue LXC::Error => e
      fail("Failed to set vlan.id: #{e.message}")
    end
  end

  def macvlan_mode
    begin
      define_container
      @container.config_item("lxc.network.macvlan_mode")
    rescue LXC::Error => e
      fail("Failed to get macvlan_mode: #{e.message}")
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
    rescue LXC::Error => e
      fail("Failed to set macvlan_mode: #{e.message}")
    end
  end

  def type
    begin
      define_container
      @container.config_item("lxc.network.type")
    rescue LXC::Error => e
      fail("Failed to get network type: #{e.message}")
    end
  end

  def type=(value)
    begin
      define_container
      @container.clear_config_item("lxc.network.type")
      @container.set_config_item("lxc.networt.type",value)
      @container.save_config
      restart if @resource[:restart]
      true
    rescue LXC::Error => e
      fail("Failed to set network type: #{e.message}")
    end
  end

  def ipv4
    begin
      define_container
      @container.config_item("lxc.network.ipv4")
    rescue LXC::Error => e
      fail("Failed to get ipv4 address: #{e.message}")
    end
  end

  def ipv4=(value)
    begin
      define_container
      @container.clear_config_item("lxc.network.ipv4")
      @container.set_config_item("lxc.network.ipv4",value.flatten)
      @container.save_config
      restart if @resource[:restart]
      true
    rescue LXC::Error => e
      fail("Failed to set ipv4 address: #{e.message}")
    end
  end

  def ipv4_gateway
    begin
      define_container
      @container.config_item("lxc.network.ipv4.gateway")
    rescue LXC::Error => e
      fail("Failed to get ipv4.gateway: #{e.message}")
    end
  end

  def ipv4_gateway=(value)
    begin
      define_container
      @container.clear_config_item("lxc.network.ipv4.gateway")
      @container.set_config_item("lxc.network.ipv4.gateway",value)
      @container.save_config
      restart if @resource[:restart]
      true
    rescue LXC::Error => e
      fail("Failed to set ipv4.gateway: #{e.message}")
    end
  end

  def flags
    begin
      define_container
      @container.config_item("lxc.network.flags")
    rescue LXC::Error => e
      fail("Failed to get flags: #{e.message}")
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
    rescue LXC::Error => e
      fail("Failed to set flags: #{e.message}")
    end
  end 

  def hwaddr
    begin
      define_container
      @container.config_item("lxc.network.hwaddr")
    rescue LXC::Error => e
      fail("Failed to get hwaddr: #{e.message}")
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
    rescue LXC::Error => e
      fail("Failed to set hwaddr: #{e.message}")
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

