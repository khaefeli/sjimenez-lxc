# Generate MAC addresses based on the results of fqdn_rand. Useful for
# generating repeatable MAC addresses for e.g. VMs.
# Inspired by https://github.com/Yelp/puppet-netstdlib
# Migrated to Puppet5 and improved by Kevin Häfeli
# Example:
#   fqdn_mac("52:54:00", "guest-1")
#   > "52:54:00:12:09:f3"

Puppet::Functions.create_function(:'fqdn_mac') do

  # validate the input
  dispatch :mac_prefix do
    #param 'Pattern[/^[0-9a-f]{2}(:[0-9a-f]{2}){0,4}$]', :mac_match

    param 'String', :mac_match
    optional_param 'String', :randomizer
  end

  # output the generated mac
  def mac_prefix(mac_match, randomizer)
    prefix_size = mac_match.split(":").size
    seed_counter = 1

    generated_mac = mac_match
    until generated_mac.split(":").size == 6 do
      seed = "#{randomizer} #{seed_counter}"
      octet_int = call_function('fqdn_rand', 60, seed)
      octet_hex = "%02x" % octet_int
      generated_mac = "#{generated_mac}:#{octet_hex}"
      seed_counter += 1
    end
    generated_mac
  end
end

