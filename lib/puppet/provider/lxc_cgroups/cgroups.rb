Puppet::Type.type(:lxc_cgroups).provide(:cgroups) do

  defaultfor :operatingsystem => :ubuntu
  confine :feature => :lxc, :kernel => 'Linux'

  attr_accessor :container, :lxc_version

  def create
    begin
      define_container
      @container.set_cgroup_item("memory.limit_in_bytes", @resource[:memory)
      @container.set_cgroup_item("cpuset.cpus", @resource[:cpuset])
      @container.save_config    
    rescue LXC::Error => e
    fail("Failed to create #{@resource[:name]}: #{e.message}")
    end
  end

  # check for exists only of the container is created
  # todo: find some cgroup options
  def exists? 
    define_container
    @container.defined?
  end


  # you can only set and get the values of a cgroup setting
  # it's not possible to unset it - so no destroy mode
  def destory
    Puppet.debug("It's not possible to absent cgroup values. please remove manually from config file")
    return false
  end
  
end
