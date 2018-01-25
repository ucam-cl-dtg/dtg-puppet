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

