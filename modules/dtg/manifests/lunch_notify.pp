class dtg::lunch_notify {
  include dtg::packages::howlermonkey
  user {'lunch':
    ensure     => present,
    home       => '/srv/lunch',
    managehome => true,
  }
  -> vcsrepo { '/srv/lunch/notify':
    ensure   => present,
    provider => git,
    user     => 'lunch',
    source   => 'ssh://git@gitlab.dtg.cl.cam.ac.uk/tb403/dtg-lunch-notify.git',
  }
  -> cron { 'dtg-lunch':
    command => '/usr/bin/python3 /srv/lunch/notify/dtg-lunch.py',
    user    => 'lunch',
    hour    => 9,
    minute  => 0,
    require => [ Python::Pip['howlermonkey'] ],
  }
}
