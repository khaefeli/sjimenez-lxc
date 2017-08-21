Puppet::Type.newtype(:lxc_cgroups) do
  @doc = 'LXC cgroups manages container limits'

  ensurable

  newparam(:container) do
    desc 'Container name'
    validate do |value|
      unless value.kind_of?String
        raise ArgumentError, "Wrong container name: #{value.class}"
      end
    end
  end

  # regex from https://github.com/claudyus/LXC-Web-Panel/blob/master/lwp/utils.py  
  newproperty(:memory) do
    desc 'memory limit in bytes'
    newvalues(/^([0-9]+|)$/)
  end

  newproperty(:cpuset) do
    desc 'cpusets to assign cpucores'
    newvalues(/^[0-9,-]+$/)
  end
  
  newparam(:name, :namevar => true) do
    desc 'Just a name'
  end

  autorequire(:lxc) do
    self[:container]
  end
end
