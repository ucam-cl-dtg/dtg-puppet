if ( $::fqdn =~ /(\w+-)?isaac-live/ ) {
}

if ( $::monitor ) {
  nagios::monitor { 'isaac-physics':
    parents    => ['balancer', 'cdn'],
    address    => 'isaacphysics.org',
    hostgroups => ['https-servers'],
  }
}
