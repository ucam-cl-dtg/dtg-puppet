node 'entropy.dtg.cl.cam.ac.uk' {
  # We don't have a local mirror of raspbian to point at
  class { 'minimal': manageapt => false, }
  class { 'dtg::entropy::host':
    certificate => '/root/puppet/ssl/stunnel.pem',
    private_key => '/root/puppet/ssl/stunnel.pem',
    ca          => '/usr/local/share/ssl/cafile',
    stage       => 'entropy-host'
  }
}
if ( $::fqdn == $::nagios_server ) {
  nagios_monitor { 'entropy':
    parents    => '',
    address    => 'entropy.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers'],
  }
}
if ( $::fqdn == $::munin_server ) {
  munin::gatherer::configure_node { 'entropy': }
}
