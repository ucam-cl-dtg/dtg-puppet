# Default setup
class dtg::firewall::default {
  # These defaults ensure that the persistence command is executed after
  # every change to the firewall, and that pre & post classes are run in the
  # right order to avoid potentially locking you out of your box during the
  # first puppet run.
  Firewall {
    notify  => Exec['persist-firewall'],
    before  => Class['dtg::firewall::post'],
    require => Class['dtg::firewall::pre'],
  }
  Firewallchain {
    notify  => Exec['persist-firewall'],
  }
}
