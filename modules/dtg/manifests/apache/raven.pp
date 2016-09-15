# Requires the apache class
class dtg::apache::raven ($server_description) {
  class {'dtg::apache::raven::repos': stage => 'repos'}
  package {'libapache2-mod-ucam-webauth':
    ensure  => present,
    require => [ Apt::Ppa['ppa:ucam-cl-dtg/ucam'], Package['apache']],
  }
  #TODO(drt24): specify server description in raven config
}
# So that we can apply a stage to it
class dtg::apache::raven::repos { # lint:ignore:autoloader_layout repos class
  apt::ppa {'ppa:ucam-cl-dtg/ucam': }
}
