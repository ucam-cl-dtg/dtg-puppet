node 'entropy.dtg.cl.cam.ac.uk' {
  # We don't have a local mirror of raspbian to point at
  class { 'dtg::minimal': manageapt => false, }
  class { 'dtg::entropy::host':
    certificate => '/root/puppet/ssl/stunnel.pem',
    private_key => '/root/puppet/ssl/stunnel.pem',
    ca          => '/usr/local/share/ssl/cafile',
    stage       => 'entropy-host'
  }
  # Allow connections to 7776
  class { 'dtg::firewall::entropy':}
}
if ( $::monitor ) {
  nagios::monitor { 'entropy':
    parents    => '',
    address    => 'entropy.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers'],
  }
}
