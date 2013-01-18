node 'dhcp.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  class { 'dhcp':
   dnsdomain    => [
                    'dtg.cl.cam.ac.uk',
                    '128.232.20.in-addr.arpa',
                    ],
    nameservers  => ['128.232.1.1'],
    ntpservers   => ['ntp0.cl.cam.ac.uk'],
    interfaces   => ['eth0'],
    dnsupdatekey => "/etc/bind/keys.d/$ddnskeyname",
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
  }
}

if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios::monitor { 'dhcp':
    parents    => '',
    address    => 'dhcp.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers, http-servers'],
  }
}

if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'dhcp': }
}
