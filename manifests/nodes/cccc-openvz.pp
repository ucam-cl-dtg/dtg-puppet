node 'cccc-openvz.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  class { 'apt::source::openvz':
    stage => 'repos'
  }
  $packagelist = ['linux-image-openvz-amd64', 'upstart-sysv', 'vzctl']
  package {$packagelist: ensure => installed,}
  ->
  virt { 'test-1':
    ensure      => 'running',
    os_template => 'ubuntu-15.10',
    virt_type   => 'openvz',
    autoboot    => 'true',
    provider    => 'openvz',
    interfaces  => ['eth0'],
    ipaddr      => ['192.168.2.1'],
    nameserver  => $::ipaddress,
    diskspace   => '4G:4G',
  }
  ->
  virt { 'test-2':
    ensure      => 'running',
    os_template => 'ubuntu-15.10',
    virt_type   => 'openvz',
    autoboot    => 'true',
    provider    => 'openvz',
    interfaces  => ['eth0'],
    ipaddr      => ['10.0.0.7'],
    nameserver  => $::ipaddress,
    diskspace   => '4G:4G',
  }
  firewall { '033 nat for openvz containers':
    table    => 'nat',
    chain    => 'POSTROUTING',
    outiface => 'eth0',
    jump     => 'MASQUERADE',
  }
  firewall { '034 forward to openvz containers':
    chain    => 'FORWARD',
    iniface  => 'eth0',
    outiface => 'venet0',
    state    => ['RELATED', 'ESTABLISHED'],
    action   => 'accept',
  }
  firewall { '034 forward from openvz containers':
    chain    => 'FORWARD',
    iniface  => 'venet0',
    outiface => 'eth0',
    action   => 'accept',
  }
  firewall { '030-dns accept tcp 53 (dns) from openvz containers':
    proto  => 'tcp',
    dport  => 53,
    source => '192.168.0.0/16',
    action => 'accept',
  }
  firewall { '031-dns accept udp 53 (dns) from openvz containers':
    proto  => 'udp',
    dport  => 53,
    source => '192.168.0.0/16',
    action => 'accept',
  }
  firewall { '030-dns accept tcp 53 (dns) from openvz containers dummy':
    proto  => 'tcp',
    dport  => 53,
    source => '10.0.0.0/16',
    action => 'accept',
  }
  firewall { '031-dns accept udp 53 (dns) from openvz containers dummy':
    proto  => 'udp',
    dport  => 53,
    source => '10.0.0.0/16',
    action => 'accept',
  }
  dtg::add_user { 'rnc1':
    real_name => 'Richard Clayton',
    groups    => 'adm',
    uid       => '1738',
  } -> 
  ssh_authorized_key {'rnc1':
    ensure => present,
    key    => 'AAAAB3NzaC1yc2EAAAABIwAAAIEAqKRiv2o4l9zOtNSyjS1kTqKK0r/4+z8VRhVQddCq+p93m19SwuA2kHDLZMy3fJRhZwuCE+F2fRNiX320/tgXjPM431mwVqZo2VcJXmZmn2HRwA+Iiakckqdc244qv/H0vlRGoPM1m156kZvKYAEa8y4pJq4azJMj+IGFf+n/+rs=',
    type   => 'ssh-rsa',
    user   => 'rnc1',
  }
}
class apt::source::openvz {
  apt::source{ 'openvz':
    location => 'http://download.openvz.org/debian',
    release  => 'wheezy',
    repos    => 'main',
    key      => {
      'id'     => 'DA2458173935F9DE9B76BA7547B5DBAB0FCA9BAC',
      'source' => 'http://download.openvz.org/debian/archive.key',
    }
  }
}
/* Not yet production
if ( $::monitor ) {
  nagios::monitor { 'HOSTNAME':
    parents    => '',
    address    => 'HOSTNAME.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::async_node { 'HOSTNAME': }
}
*/
