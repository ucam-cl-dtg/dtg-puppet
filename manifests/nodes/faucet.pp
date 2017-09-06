node 'faucet.sec.cl.cam.ac.uk' {

  $packages = ['build-essential', 'libpcap-dev']

  class { 'dtg::minimal':
    user_whitelist => ['drt24', 'rnc1', 'rss39']
  }
  

  package{$packages:
    ensure => installed,
  }
  
}

if ( $::monitor ) {
  nagios::monitor { 'faucet':
    parents    => '',
    address    => 'faucet.sec.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers'],
  }
  
  munin::gatherer::async_node { 'faucet':
    full_hostname => 'faucet.sec.cl.cam.ac.uk',
  }
}
