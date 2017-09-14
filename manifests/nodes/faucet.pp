node 'faucet.sec.cl.cam.ac.uk' {

  $packages = ['build-essential', 'libpcap-dev']

  class { 'dtg::minimal':
    user_whitelist      => ['drt24', 'rnc1', 'rss39'],
    firewall_ssh_source => $::local_subnet, # sysadmin firewall should also enforce this
  }

  User<|title == rss39 |> { groups +>[ 'adm' ] }

  dtg::add_user { 'rnc1':
    real_name => 'Richard Clayton',
    groups    => 'adm',
    uid       => '1738',
  } ->
  ssh_authorized_key {'rnc1':
    ensure => present,
    key    => 'AAAAB3NzaC1yc2EAAAABIwAAAIEAqKRiv2o4l9zOtNSyjS1kTqKK0r/4+z8VRhVQddCq+p93m19SwuA2kHDLZMy3fJRhZwuCE+F2fRNiX320/tgXjPM431mwVqZo2VcJXmZmn2HRwA+Iiakckqdc244qv/H0vlRGoPM1m156kZvKYAEa8y4pJq4azJMj+IGFf+n/+rs=',
    type   => 'ssh-rsa',
    user   => 'rnc1',
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
