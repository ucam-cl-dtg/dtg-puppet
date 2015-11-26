class dtg::vm {
  class {'dtg::vm::repos': stage => 'repos'}
  if $::operatingsystem == 'Ubuntu' {
    package {'xe-guest-utilities':
      ensure  => latest,
      require => Apt::Ppa['ppa:retrosnub/xenserver-support'],
    }
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
  exec {'xenstore-write-sudoers':
    command => 'sudo xenstore-write "data/sudoers" "$(for x in `ls /etc/sudoers.d`; do getent group $x; done | cut -d \':\' -f 4 |  tr \',\' \'\n\' | sort | uniq | grep -e  ^[a-z]*[a-z][0-9][0-9]*$ | sed \':a;N;$!ba;s/\n/ /g\')"'
  }

  # Autologin as root

  file{'/etc/systemd/system/serial-getty@hvc0.service.d/':
    ensure => 'directory',
  }
  ->
  file{'/etc/systemd/system/serial-getty@hvc0.service.d/autologin.conf':
    ensure => file,
    source => 'puppet:///modules/dtg/autologin.conf',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

}
# So that we can appy a stage to it
class dtg::vm::repos {
  # This is Malcolm Scott's ppa containing xe-guest-utilities which installs
  # XenServer tools which we want on every VM.
  if $::operatingsystem == 'Ubuntu' {
    apt::ppa {'ppa:retrosnub/xenserver-support': }
  }
}
