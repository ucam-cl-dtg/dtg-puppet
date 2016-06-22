node /naps-corpus/ {
  include 'dtg::minimal'

  $packages = ['build-essentials','ghc']

  package{$packages:
    ensure => installed,
  }
  
}

if ( $::monitor ) {
  nagios::monitor { 'naps-corpus':
    parents    => 'nas04',
    address    => 'naps-corpus.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers'],
  }
  
  munin::gatherer::async_node { 'naps-corpus': }
}
