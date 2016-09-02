class dtg::entropy::host ($certificate, $private_key, $ca, $crl = false){
  if ! defined(Class['dtg::entropy']) {
    fail("Class['dtg::entropy'] must be defined")
  }
  group { 'egd-host': ensure => present, }
  user { 'egd-host':
    gid     => 'egd-host',
    comment => 'Entropy Generating Device user',
    ensure  => present,
  }
  file { '/var/lib/stunnel4/egd-host':
    ensure  => directory,
    owner   => 'egd-host',
    group   => 'egd-host',
    mode    => '0700',
    require => Package[$stunnel::data::package],
  }
  stunnel::tun { 'egd-host':
    cert     => $certificate,
    key      => $private_key,
    cafile   => $ca,
    crlfile  => $crl,
    chroot   => '/var/lib/stunnel4/egd-host',
    pid      => '/egd-host.pid',
    output   => '/egd-host.log',
    user     => 'egd-host',
    group    => 'egd-host',
    services => {'egd-host'    => {accept    => '7776'}},
    connect  => '777',
    client   => false,
    protocol => false,
    require  => User['egd-host'],
  }
  class { 'ekeyd':
    host      => true,
    port      => '777',
    masterkey => '',
    stage     => $stage,
  }
  class { 'sysctl::base':
    stage => $stage,
  }
}
