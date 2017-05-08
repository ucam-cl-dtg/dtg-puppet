class dtg::entropy::client ($cafile, $host_address, $host_port = '7776', $local_port = '7777') {
  if ! defined(Class['dtg::entropy']) {
    fail("Class['dtg::entropy'] must be defined")
  }
  group { 'egd-client': ensure => present, }
  user { 'egd-client':
    ensure  => present,
    gid     => 'egd-client',
    comment => 'Entropy Generating Device client user',
  }
  file { '/var/lib/stunnel4/egd-client':
    ensure  => directory,
    owner   => 'egd-client',
    group   => 'egd-client',
    mode    => '0700',
    require => Package[$stunnel::data::package],
  }
  stunnel::tun { 'egd-client':
    cafile   => $cafile,
    chroot   => '/var/lib/stunnel4/egd-client',
    pid      => '/egd-client.pid',
    output   => '/egd-client.log',
    user     => 'egd-client',
    group    => 'egd-client',
    services => {
      'egd-client' => {
        accept => $local_port
      }
    },
    connect  => "${host_address}:${host_port}",
    client   => true,
    verify   => 3,
    protocol => false,
    require  => User['egd-client'],
  }
  class { 'ekeyd::client':
    host => 'localhost',
    port => '7777',
  }
}
