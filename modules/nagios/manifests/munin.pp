class nagios::munin {
  file {'/usr/local/bin/check_munin_rrd.pl':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => 'u+rwx,a+rx',
    source => 'puppet:///modules/munin/nagios-munin/check_munin_rrd.pl'
  }
}
