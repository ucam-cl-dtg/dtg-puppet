class dtg::vm {
  class {'dtg::vm::repos': stage => 'repos'}
  package {'xe-guest-utilities':
    ensure => present,
    require => Apt::Ppa['ppa:retrosnub/xenserver-support'],
  }
}
# So that we can appy a stage to it
class dtg::vm::repos {
  # This is Malcolm Scott's ppa containing xe-guest-utilities which installs
  # XenServer tools which we want on every VM.
  apt::ppa {'ppa:retrosnub/xenserver-support': }
}
