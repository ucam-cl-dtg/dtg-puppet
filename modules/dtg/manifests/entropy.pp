# Entropy server
# Relies on the ekeyd and stunnel modules
class dtg::entropy {
  class { 'stunnel': stage => $stage, }

  # The Filesystem Hierachy Standard says we can assume that /usr/local/share exists
  
  file {'/usr/local/share/ssl/':
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }
  file {'/usr/local/share/ssl/cafile':
    ensure => file,
    source => 'puppet:///modules/dtg/ssl/cafile',
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
  }
}
