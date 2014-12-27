class dtg::vm {
  class {'dtg::vm::repos': stage => 'repos'}
  package {'xe-guest-utilities':
    ensure  => latest,
    require => Apt::Ppa['ppa:retrosnub/xenserver-support'],
  }
  package {'mingetty':
    ensure => latest,
  }

  file { '/etc/init/hvc0.conf':
    source => 'puppet:///modules/dtg/hvc0.conf',
    ensure => present,
    owner  => 'root',
    group  => 'root'
  }
  file {'/etc/init.d/vm-boot.sh':
    ensure => file,
    source => 'puppet:///modules/dtg/vm-boot.sh',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  file {'/etc/rc2.d/S76vm-boot':
    ensure => 'link',
    target => '/etc/init.d/vm-boot.sh'
  }
}
# So that we can appy a stage to it
class dtg::vm::repos {
  # This is Malcolm Scott's ppa containing xe-guest-utilities which installs
  # XenServer tools which we want on every VM.
  apt::ppa {'ppa:retrosnub/xenserver-support': }
}
