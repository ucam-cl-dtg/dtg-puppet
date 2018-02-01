node 'cccc-maltego.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  dtg::add_user { 'rnc1':
    real_name => 'Richard Clayton',
    groups    => ['adm', 'cccc-data'],
    uid       => '1738',
  } ->
  ssh_authorized_key {'rnc1':
    ensure => present,
    key    => 'AAAAB3NzaC1yc2EAAAABIwAAAIEAqKRiv2o4l9zOtNSyjS1kTqKK0r/4+z8VRhVQddCq+p93m19SwuA2kHDLZMy3fJRhZwuCE+F2fRNiX320/tgXjPM431mwVqZo2VcJXmZmn2HRwA+Iiakckqdc244qv/H0vlRGoPM1m156kZvKYAEa8y4pJq4azJMj+IGFf+n/+rs=',
    type   => 'ssh-rsa',
    user   => 'rnc1',
  }
  dtg::add_user { 'ah793':
    real_name => 'Alice Hutchings',
    uid       => '3308',
    groups    => 'cccc-data',
  } ->
  ssh_authorized_key {'ah793':
    ensure => present,
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQDASSD6MvZH7uFbmz5rKtX9ht+4DO83Vu7SkpEdc1JPBkn3dO6xs5zZyjMWzADuckv/zu0e85RMvbBk59Rs58qzjPy3e7mEHHAcD8znFE2LCgsNUeC6DT6iYfv+v+MKxtzuxzNN5yH0SOOF2ArBVSGu9sGELT5BRYfO3iWJKAsvRMLegjJzOsQKScx7URJbgHEDmRgMSHImi8UucrGOJD1Z+3xQCAWk8tWZZDsoaFKn9YldzPxNbCB0Z6zsDlzjQeWTEjab312aF1567i++1g+BfuRsS4HSj2Rif8D1inPVhlR63aTddePQ4V9OkBwbBUpJ8W1aoq5aEwlHDcnKGa/5+FPrSPQoWtnGe87uFFOqztrPhDYFi1UP16mEl01tbjnzNZyKXTTnSvGzD7CY5T28ji+XTHpHSPlBn3Sixhivx83XwSk4KqikZ4jy0nkk8JF8pTjXFh6lJlECmHXvbsz0YrCSpGU8TUBa7S44ibFTF/x/Lx2QDJcKpJBBhgscUvuIF0RXBbZ/RBE9rO7XbilwaVKJ7FjWyKh4OwMJdZSUK7WnL+phRfDmo862q3yJ1bcu/eV0aYmtMorALPczgVszRxwAFsiuePPeiIDiwyv8hh6XsTgC/+oLddKMTcvTT+B/EatRCEqJN1exubXpwW6pUQoj+MYnOuV6vJ7ZXxJ12w==',
    type  => 'ssh-rsa',
    user  => 'ah793',
  }
  dtg::add_user { 'maltego':
    real_name => 'Maltego User',
    groups    => ['cccc-data'],
    uid       => '1369',
    keys      => [
      'Daniel Robert Thomas (Computer Lab Key) <drt24@cam.ac.uk>'],
  } ->
  ssh_authorized_key {'maltego-rnc1':
    ensure => present,
    key    => 'AAAAB3NzaC1yc2EAAAABIwAAAIEAqKRiv2o4l9zOtNSyjS1kTqKK0r/4+z8VRhVQddCq+p93m19SwuA2kHDLZMy3fJRhZwuCE+F2fRNiX320/tgXjPM431mwVqZo2VcJXmZmn2HRwA+Iiakckqdc244qv/H0vlRGoPM1m156kZvKYAEa8y4pJq4azJMj+IGFf+n/+rs=',
    type   => 'ssh-rsa',
    user   => 'maltego',
  } ->
  ssh_authorized_key {'maltego-ah793':
    ensure => present,
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQDASSD6MvZH7uFbmz5rKtX9ht+4DO83Vu7SkpEdc1JPBkn3dO6xs5zZyjMWzADuckv/zu0e85RMvbBk59Rs58qzjPy3e7mEHHAcD8znFE2LCgsNUeC6DT6iYfv+v+MKxtzuxzNN5yH0SOOF2ArBVSGu9sGELT5BRYfO3iWJKAsvRMLegjJzOsQKScx7URJbgHEDmRgMSHImi8UucrGOJD1Z+3xQCAWk8tWZZDsoaFKn9YldzPxNbCB0Z6zsDlzjQeWTEjab312aF1567i++1g+BfuRsS4HSj2Rif8D1inPVhlR63aTddePQ4V9OkBwbBUpJ8W1aoq5aEwlHDcnKGa/5+FPrSPQoWtnGe87uFFOqztrPhDYFi1UP16mEl01tbjnzNZyKXTTnSvGzD7CY5T28ji+XTHpHSPlBn3Sixhivx83XwSk4KqikZ4jy0nkk8JF8pTjXFh6lJlECmHXvbsz0YrCSpGU8TUBa7S44ibFTF/x/Lx2QDJcKpJBBhgscUvuIF0RXBbZ/RBE9rO7XbilwaVKJ7FjWyKh4OwMJdZSUK7WnL+phRfDmo862q3yJ1bcu/eV0aYmtMorALPczgVszRxwAFsiuePPeiIDiwyv8hh6XsTgC/+oLddKMTcvTT+B/EatRCEqJN1exubXpwW6pUQoj+MYnOuV6vJ7ZXxJ12w==',
    type  => 'ssh-rsa',
    user  => 'maltego',
  }
  file{'/usr/local/bin/start-maltego.sh':
    ensure  => file,
    mode    => 'u+rwx,og+rx',
    owner   => 'root',
    group   => 'root',
    content => '#!/usr/bin/env bash
set -e
authority=$(xauth -f ~/.Xauthority list| tail -1)
sudo -u maltego bash -c "xauth add \"$authority\"
/usr/bin/maltego"
',
}
  ->
  sudoers::allowed_command{ 'maltego':
    command          => 'ALL',
    group            => 'cccc-data',
    run_as           => 'maltego',
    require_password => false,
    comment          => 'Allow cccc users to run maltego as the maltego user',
  }
  class { 'java': }
}

if ( $::monitor ) {
  nagios::monitor { 'cccc-maltego':
    parents    => 'nas04',
    address    => 'cccc-maltego.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::async_node { 'cccc-maltego': }
}

