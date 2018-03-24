node /naps-corpus/ {
  
  User<|title == mrd45 |> { groups +>[ 'adm' ]}

  $packages = ['build-essential','ghc','libblas-dev','liblapack-dev','libpcre3-dev']

  class { 'dtg::minimal':
    user_whitelist => ['acr31','dao29','mojpc2','mrd45','drt24']
  }
  

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
