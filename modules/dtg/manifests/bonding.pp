class dtg::bonding ($address, $netmask = '255.255.252.0', $network = '128.232.20.0', $broadcast = '128.232.23.255', $gateway = '128.232.20.1', $dns_nameservers = $::dns_name_servers, $dns_search = 'dtg.cl.cam.ac.uk'){

  # bonded nics
  dtg::kernelmodule::add{"bonding": }

  package{'ifenslave':
    ensure => installed
  }

  class { 'network::interfaces':
    interfaces => {
      'eth0' => {
        'method'      => 'manual',
        'bond-master' => 'bond0',
      },
      'eth1' => {
        'method'      => 'manual',
        'bond-master' => 'bond0',
      },
      'bond0' => {
        'method'          => 'static',
        'address'         => $address,
        'netmask'         => $netmask,
        'network'         => $network,
        'broadcast'       => $broadcast,
        'gateway'         => $gateway,
        'dns-nameservers' => $dns_nameservers,
        'dns-search'      => $dns_search,
        'bond-mode'       => '4',
        'bond-miimon'     => '100',
        'bond-lacp-rate'  => '1',
        'bond-slaves'     => 'eth0 eth1'
      }
    },
    auto       => ['eth0', 'eth1', 'bond0'],
  }

}
