node 'dhcp.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  class {'apache': }
  apache::site {'open-room-map':
    source => 'puppet:///modules/dtg/apache/default.conf',
  }


  class { 'network::interfaces':
    interfaces => {
      'eth0' => {
        'method' => 'static',
        'address' => '128.232.20.36',
        'netmask' => '255.255.255.0',
        'gateway' => '128.232.97.33',
      }
    },
    auto => ["eth0"],
  }

  class { 'dhcp':
   dnsdomain    => [
                    'dtg.cl.cam.ac.uk',
                    '128.232.20.in-addr.arpa',
                    ],
    nameservers  => ['128.232.1.1'],
    ntpservers   => $ntp_servers,
    interfaces   => ['eth0'],

  }

  dhcp::pool{ 'dtg.cl.cam.ac.uk':
    network => '128.232.20.0',
    mask    => '255.255.255.0',
    range   => '128.232.20.28 128.232.20.43',
    gateway => '128.232.20.18',
  }
  dhcp::host {
    'puppy0':mac => "00:16:3E:E8:14:1C", ip => "128.232.20.28";
    'puppy1':mac => "00:16:3E:E8:14:1D", ip => "128.232.20.29";
    'puppy2':mac => "00:16:3E:E8:14:1E", ip => "128.232.20.30";
    'puppy3':mac => "00:16:3E:E8:14:1F", ip => "128.232.20.31";
    'puppy4':mac => "00:16:3E:E8:14:20", ip => "128.232.20.32";
    'puppy5':mac => "00:16:3E:E8:14:21", ip => "128.232.20.33";
    'puppy6':mac => "00:16:3E:E8:14:22", ip => "128.232.20.34";
    'puppy7':mac => "00:16:3E:E8:14:23", ip => "128.232.20.35";
    'puppy8':mac => "00:16:3E:E8:14:24", ip => "128.232.20.36";
    'puppy9':mac => "00:16:3E:E8:14:25", ip => "128.232.20.37";
    'puppy10':mac => "00:16:3E:E8:14:26", ip => "128.232.20.38";
    'puppy11':mac => "00:16:3E:E8:14:27", ip => "128.232.20.39";
    'puppy12':mac => "00:16:3E:E8:14:28", ip => "128.232.20.40";
    'puppy13':mac => "00:16:3E:E8:14:29", ip => "128.232.20.41";
    'puppy14':mac => "00:16:3E:E8:14:2A", ip => "128.232.20.42";
    'puppy15':mac => "00:16:3E:E8:14:2B", ip => "128.232.20.43";
    'puppy16':mac => "00:16:3E:E8:14:2C", ip => "128.232.20.44";
    'puppy17':mac => "00:16:3E:E8:14:2D", ip => "128.232.20.45";
    'puppy18':mac => "00:16:3E:E8:14:2E", ip => "128.232.20.46";
    'puppy19':mac => "00:16:3E:E8:14:2F", ip => "128.232.20.47";
    'puppy20':mac => "00:16:3E:E8:14:30", ip => "128.232.20.48";
    'puppy21':mac => "00:16:3E:E8:14:31", ip => "128.232.20.49";
    'puppy22':mac => "00:16:3E:E8:14:32", ip => "128.232.20.50";
    'puppy23':mac => "00:16:3E:E8:14:33", ip => "128.232.20.51";
    'puppy24':mac => "00:16:3E:E8:14:34", ip => "128.232.20.52";
    'puppy25':mac => "00:16:3E:E8:14:35", ip => "128.232.20.53";
    'puppy26':mac => "00:16:3E:E8:14:36", ip => "128.232.20.54";
    'puppy27':mac => "00:16:3E:E8:14:37", ip => "128.232.20.55";
    'puppy28':mac => "00:16:3E:E8:14:38", ip => "128.232.20.56";
    'puppy29':mac => "00:16:3E:E8:14:39", ip => "128.232.20.57";
    'puppy30':mac => "00:16:3E:E8:14:40", ip => "128.232.20.58";
    'puppy31':mac => "00:16:3E:E8:14:4A", ip => "128.232.20.59";
  }
}

if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios::monitor { 'dhcp':
    parents    => '',
    address    => 'dhcp.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
}

if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'dhcp': }
}
