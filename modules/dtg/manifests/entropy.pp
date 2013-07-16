# Entropy server
# Relies on the ekeyd and stunnel modules
class dtg::entropy {
  class { 'stunnel': stage => $stage, }

  # The Filesystem Hierachy Standard says we can assume that /usr/local/share exists
  
  file {'/usr/local/share/ssl/':
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }
  file {'/usr/local/share/ssl/cafile':
    ensure => file,
    source => 'puppet:///modules/dtg/ssl/cafile',
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
  }
}
class dtg::entropy::host ($certificate, $private_key, $ca, $crl = false){
  if ! defined(Class['dtg::entropy']) {
    fail("Class['dtg::entropy'] must be defined")
  }
  group { 'egd-host': ensure => present, }
  user { 'egd-host':
    gid => 'egd-host',
    comment => 'Entropy Generating Device user',
    ensure => present,
  }
  file { '/var/lib/stunnel4/egd-host':
    ensure => directory,
    owner  => 'egd-host',
    group  => 'egd-host',
    mode   => 700,
    require => Package[$stunnel::data::package],
  }
  stunnel::tun { 'egd-host':
    cert        => $certificate,
    key         => $private_key,
    cafile      => $ca,
    crlfile     => $crl,
    chroot      => '/var/lib/stunnel4/egd-host',
    pid         => '/egd-host.pid',
    output      => '/egd-host.log',
    user        => 'egd-host',
    group       => 'egd-host',
    services    => {'egd-host' => {accept => '7776'}},
    connect     => '777',
    client      => false,
    protocol    => false,
    require     => User['egd-host'],
  }
  class { 'ekeyd':
    host => true,
    port => '777',
    masterkey => '',
  }
}
class dtg::entropy::client ($cafile, $host_address, $host_port = '7776', $local_port = '7777') {
  if ! defined(Class['dtg::entropy']) {
    fail("Class['dtg::entropy'] must be defined")
  }
  group { 'egd-client': ensure => present, }
  user { 'egd-client':
    gid => 'egd-client',
    comment => 'Entropy Generating Device client user',
    ensure => present,
  }
  file { '/var/lib/stunnel4/egd-client':
    ensure => directory,
    owner  => 'egd-client',
    group  => 'egd-client',
    mode   => 700,
    require => Package[$stunnel::data::package],
  }
  stunnel::tun { 'egd-client':
    cafile      => $cafile,
    chroot      => '/var/lib/stunnel4/egd-client',
    pid         => '/egd-client.pid',
    output      => '/egd-client.log',
    user        => 'egd-client',
    group       => 'egd-client',
    services    => { 'egd-client' => {accept => $local_port}},
    connect     => "${host_address}:${host_port}",
    client      => true,
    verify      => 3,
    protocol    => false,
    require     => User['egd-client'],
  }
  class { 'ekeyd::client':
    host => 'localhost',
    port => '7777',
  }
}
