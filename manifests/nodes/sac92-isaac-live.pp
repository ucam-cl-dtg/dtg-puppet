node /(\w+-)?isaac-live/ {
  dtg::backup::serversetup{'Mongodb backup':
    backup_directory   => '/local/data/rutherford/database-backup',
    script_destination => '/usr/share/isaac/backup',
    user               => 'isaac',
    home               => '/usr/share/isaac/',
  }
  
  if ( $::monitor ) {
    nagios::monitor { 'isaac-live':
      parents    => 'nas04',
      address    => 'isaac-live.dtg.cl.cam.ac.uk',
      hostgroups => [ 'ssh-servers' , 'http-servers' ],
    }
    munin::gatherer::configure_node { 'isaac-live': }

    nagios::monitor { 'isaac-physics':
      parents    => ['isaac-live', 'balancer'],
      address    => 'isaacphysics.org',
      hostgroups => ['https-servers'],
    }
  }
}
