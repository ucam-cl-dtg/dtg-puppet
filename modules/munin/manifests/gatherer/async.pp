class munin::gatherer::async(
) {
  require 'munin::gatherer'
  dtg::sshkeygen{'munin':
    homedir => '/var/lib/munin',
    # This require is actually meant for the whole class but I don't know how to do that (drt24).
    require => Package['munin-async'],
  }
}
