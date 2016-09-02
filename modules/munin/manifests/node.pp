class munin::node (
  $node_allow_ips = ['^127\.0\.0\.1$'],
  $node_timeout = '30',
  $async = true,
  $async_key = '',
) {
  package { [ 'munin-node', 'munin-plugins-extra', 'libcache-cache-perl' ]:
    ensure => installed
  } ->
  exec { 'munin-node-configure':
    command  => 'munin-node-configure --shell | sh',
    provider => shell,
  } ->
  service { 'munin-node':
    ensure => running
  }

  if $async {
    package { 'munin-async':
      ensure => installed,
    } ->
    service { 'munin-async':
      ensure  => running,
      require => Service['munin-node'],
    } ->
    ssh_authorized_key { 'munin-async':
      user    => 'munin-async',
      type    => 'ssh-rsa',
      key     => $async_key,
      ensure  => 'present',
      options => ['no-port-forwarding', 'no-agent-forwarding', 'no-X11-forwarding', 'no-pty', 'no-user-rc', 'command="/usr/share/munin/munin-async --spoolfetch"']
    }
  }

  file { '/etc/munin/munin-node.conf':
    ensure  => present,
    content => template('munin/munin-node.conf.erb'),
    require => Package['munin-node'],
    notify  => Service[ 'munin-node']
  }
  # Overrides for default content of munin-node so that we don't get noise from filesystems coming and going
  # Also specify the user required for the unbound plugins
  file { '/etc/munin/plugin-conf.d/z-overrides':
    ensure  => file,
    content => '[df*]
    env.warning 92
    env.critical 98
    env.exclude none unknown binfmt_misc debugfs devtmpfs fuse.gvfs-fuse-daemon iso9660 ramfs romfs rpc_pipefs squashfs tmpfs udf
[diskstats]
    env.exclude none unknown ok
[unbound*]
    user root
    env.statefile /var/lib/munin-node/plugin-state/unbound-state
    env.unbound_conf /etc/unbound/unbound.conf
    env.unbound_control /usr/sbin/unbound-control
',
    require => Package['munin-node'],
    notify  => Service[ 'munin-node'],
  }
}
