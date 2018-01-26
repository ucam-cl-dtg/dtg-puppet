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
  }
  dtg::user { 'maltego':
    real_name  => 'Maltego User',
    groups   => ['cccc-data'],
    keys     => [
      'Daniel Robert Thomas (Computer Lab Key) <drt24@cam.ac.uk>'],
  } ->
  ssh_authorized_key {'maltego-rnc1':
    ensure => present,
    key    => 'AAAAB3NzaC1yc2EAAAABIwAAAIEAqKRiv2o4l9zOtNSyjS1kTqKK0r/4+z8VRhVQddCq+p93m19SwuA2kHDLZMy3fJRhZwuCE+F2fRNiX320/tgXjPM431mwVqZo2VcJXmZmn2HRwA+Iiakckqdc244qv/H0vlRGoPM1m156kZvKYAEa8y4pJq4azJMj+IGFf+n/+rs=',
    type   => 'ssh-rsa',
    user   => 'maltego',
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

