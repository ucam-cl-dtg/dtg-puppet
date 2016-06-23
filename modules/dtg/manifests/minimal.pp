class dtg::minimal ($manageapt = true, $adm_sudoers = true, $manageentropy = true, $managefirewall = true, $dns_server = false) {

  # Set up the repositories, get some entropy then do everything else
  #  entropy needs to start being provided before it is consumed
  # Do DNS last as fiddling with that while doing other things can cause other
  #  things to fail
  stage {'dns': } Stage['main'] -> Stage['dns']
  stage {'entropy': before => Stage['main'] }
  stage {'entropy-host': before => Stage['entropy'] }
  stage {'repos': before => Stage['entropy-host'] }
  # Manage apt sources lists
  if $manageapt {
    if $::operatingsystem == 'Ubuntu' {
      class { 'aptrepository':
        repository => 'http://www-uxsup.csx.cam.ac.uk/pub/linux/ubuntu/',
        stage      => 'repos'
      }
    }
    if $::operatingsystem == 'Debian' {
      class { 'aptrepository':
        repository => 'http://www-uxsup.csx.cam.ac.uk/pub/linux/debian/',
        stage      => 'repos'
      }
    }
  }

  # Packages which should be installed on all servers
  $packagelist = ['traceroute', 'vim', 'screen', 'fail2ban', 'curl', 'tar',
                  'apg', 'htop', 'emacs24-nox',
                  'iptables-persistent', 'command-not-found', 'mlocate',
                  'bash-completion', 'apt-show-versions', 'iotop', 'byobu', 'parted']
  package {
    $packagelist:
      ensure => installed
  }

  if ! $::virtual == 'openvzve' {
    package {
      'nfs-common':
        ensure => installed
    }
  }

  if $::operatingsystem == 'Debian' or $::virtual == 'openvzve' {
    $os_extralist = []
  } else {
    $os_extralist = ['linux-image-generic']
  }

  package {
    $os_extralist:
      ensure => installed
  }

  # Packages that should not be installed on a server
  $banned_packages = ['sl', 'emacs23-common', 'emacs23-bin-common', 'whoopsie', 'locate', 'runit']

  package {
    $banned_packages:
      ensure => purged
  }

  if ($virtual == 'xenu') and $manageapt {
    class {'dtg::vm':}
  }
  if ($virtual == 'physical') and $manageapt {
    class {'dtg::baremetal':}
  }

  class { 'monkeysphere::sshd':
    max_startups         => '',
    agent_forwarding     => 'yes',
    tcp_forwarding       => 'yes',
    x11_forwarding       => 'yes',
    listen_address       => [ '0.0.0.0', '::' ],
    
    # Set use_pam to yes so that we trigger the pam_motd printing module
    # We leave Passwords and ChallengeResponse set to no
    use_pam              => 'yes',

    # sometimes we need to give ad-hoc access to people not in monkeysphere.  This turns on
    # the normal authorized_keys file if we need it
    authorized_keys_file => '/var/lib/monkeysphere/authorized_keys/%u .ssh/authorized_keys',
  }

  class { 'dtg::dns':
    dns_server => $dns_server,
    stage => 'dns',
  }
  class { 'dtg::git::config': }
  class { 'dtg::rsyslog': }
  class { 'etckeeper': require => Class['dtg::git::config'] }
  class { 'ntp': servers => $ntp_servers, package_ensure => latest, }
  # Get entropy then do gpg and then monkeysphere
  if $manageentropy {
    class { 'dtg::entropy': stage => 'entropy-host' }
    class { 'dtg::entropy::client':
      cafile       => '/usr/local/share/ssl/cafile',
      host_address => 'entropy.dtg.cl.cam.ac.uk',
      stage        => 'entropy',
      require      => File['/usr/local/share/ssl/cafile'],
    }
  }

  # Make it possible to send email (if correct from address is used)
  class { 'dtg::email': }

  class { 'gpg': }
  class { 'monkeysphere':
    keyserver => $::ms_keyserver,
    require => Class['dtg::email'],
  }
  # create hourly cron job to update users authorized_user_id files
  $ms_min = random_number(60)
  file { '/etc/cron.d/monkeysphere':
    content => template('monkeysphere/monkeysphere.erb'),
    owner   => root,
    group   => root,
    replace => no,
    mode    => '0644'
  }
  # ensure our ssh key is imported into the monkeysphere
  monkeysphere::import_key { 'main': }
  monkeysphere::publish_server_keys { 'main':}
## This stuff is important but currently broken TODO(drt24) fix it.
#  gpg::private_key {'root':
#    homedir => '/root',
#    passphrase => $::ms_gpg_passphrase,
#  }
#  monkeysphere::auth_capable_user {'root':
#    passphrase => $::ms_gpg_passphrase,
#    home       => '/root',
#    require    => Gpg::Private_key['root'],
#  }
#  file {'/root/.ssh/':
#    ensure => directory,
#    owner  => 'root',
#    group  => 'root',
#    mode   => '0700',
#  }
#  monkeysphere::trusting_user{'root':
#    passphrase => $::ms_gpg_passphrase,
#    require    => Monkeysphere::Auth_capable_user['root'],
#    home       => '/root/'
#  }
#  monkeysphere::ssh_agent { 'root':
#    passphrase => $::ms_gpg_passphrase,
#    require    => Monkeysphere::Auth_capable_user['root'],
#  }

  # Add the certifiers who sign the users
  class { 'ms_id_certifiers': }
  monkeysphere::authorized_user_ids { 'root':
    user_ids => $ms_admin_user_ids
  }
  # Create the admin users
  class { 'admin_users':
    require => Class['dtg::email'],
  }
  # Allow admin users to push puppet config
  if $adm_sudoers {
    group { 'adm': ensure => present }
    # Make admin users admin users
    sudoers::allowed_command{ 'adm':
      command          => 'ALL',
      group            => 'adm',
      run_as           => 'ALL',
      require_password => false,
      comment          => 'Allow members of the admin group to use sudo to get root on low-security boxes',
    }
  }
  else {
    file {'/etc/sudoers.d/adm':
      ensure => absent,
    }
  }
  group { 'dtg-admin': ensure => present }
  # Make dtg-admin users have root on all high-security boxes (eg nas0{1,4})
  sudoers::allowed_command{ 'dtg-adm':
      command          => 'ALL',
      group            => 'dtg-adm',
      run_as           => 'ALL',
      require_password => false,
      comment          => 'Allow members of the dtg-admin group to use sudo to get root on high-security boxes',
    }
  class { 'dtg::unattendedupgrades':
    unattended_upgrade_notify_emailaddress => $::unattended_upgrade_notify_emailaddress,
    require                                => Class['dtg::email'],
  }

  # Monitor using munin
  class { 'munin::node':
    node_allow_ips => [ escapeRegexp($::munin_server_ip), '^127\.0\.0\.1$' ],
    node_timeout   => '60',
    async_key      => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQC688SXcu+yWt+n2AVxb5hCnVt9W57EaIvtPdzKtUO1U+ErXa3urWdJ0Y7/X+8Jzly9v6lAFUYHrjo4AYWnO9pRymBBWHJxx3oZMFuQXxJ7F0HPztMBB1rcsLqEyILzg3M8uvqFqAuxIBzraO51V2qn+f/nSmREd4T88qIo2Vt8Y9jfr3HLAxyZ5TOXJu9fCnJMdcEYx7PdK6O7YeolNQ6UZINpHa5xpeaXGkho1bsCmcYphU/UFrhpVkp0wIw40FkJLP/qyUrKoJ32CSiro0OnovG+8nuXedJ8FmgTBHQP1J+Xw2Bykxka3cfw2RhWybNKBq2AnTCjZkyEN2wCKFCL+UHWKdporYksovZw2BDIbA0zOrROra7BMDFul1TGx0VFW9gCs6/K7uWWxUgWDYnyhnF49sAE4kdClY66DLLh0LSbw4YojB+PRbXHnDGcim9RXWtewy7mC/5ns2nsoQ5jx7Fol6RC+2Ko4X/fmQ4yc7LruEBDxwhSB+SgMNH/y2piQtaaFXBzOTnmdyTIA3iD1ZVBviQkFRWocGXYViFtqqXtODYUHSOKIHiksSiaE8ItCTwb3lV1aCmlLAebCpU48l5g6OwJtYn/KdWBVwNxAb+TWNeJZcMu00Z2lsXYoPZy7GGVFfHWztLgn1UgstPdTr5zc6g6IlT5lfKbyGof+w==',
  }
  munin::node::plugin{ 'apt_ubuntu':
    target => '/etc/puppet/modules/munin/files/contrib/plugins/ubuntu/apt_ubuntu',
  }
  package {'libnet-dns-perl':
    ensure => installed,
  } ->
  file { '/usr/share/munin/plugins/dnsresponse_':
    ensure  => file,
    source  => 'puppet:///modules/munin/contrib/plugins/network/dns/dnsresponse_',
    mode    => '0755',
    require => Package['munin-node'],
    notify  => [Exec['munin-node-configure'], Service['munin-node']],
  }
  file {'/etc/munin/plugins/dnsresponse_':# Oops, configured it wrong
    ensure => absent,
  }
  # Add read only filesystem detection plugin
  file {'/usr/share/munin/plugins/fs_readonly':
    ensure  => file,
    source  => 'puppet:///modules/dtg/munin/fs_readonly',
    mode    => '0755',
    require => Package['munin-node'],
  }
  munin::node::plugin{'fs_readonly':}
  munin::node::plugin{'df_abs':}

  if ($virtual == 'physical') {
    munin::node::plugin{'hddtemp_smartctl':}
    munin::node::plugin{'sensors_fan': target => 'sensors_'}
    munin::node::plugin{'sensors_temp': target => 'sensors_'}
    munin::node::plugin{'sensors_volt': target => 'sensors_'}
  }

  # Include default firewall rules

  if $managefirewall {
    class { 'dtg::firewall': }
  }
  
  sshkey {'localhost':
    ensure       => present,
    host_aliases => [$::fqdn, $::hostname],
    key          => $::sshrsakey,
    type         => 'rsa',
  }
  file {'/etc/ssh_known_hosts':# Puppet does not create a world readable file
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Sshkey['localhost'],
  }

  # Disable ipv6 privacy extensions so that machines have predictable ipv6 addresses
  file {'/etc/sysctl.d/11-ipv6-privacy.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/dtg/11-ipv6-privacy.conf'
  }

  file {'/etc/modprobe.d/options-nfs.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "options nfs callback_tcpport=${::nfs_client_port}",
  }

  if $::operatingsystem != 'Debian' and $::virtual != 'openvzve' {
    # Attempt to make DNS more robust by timing out quickly and retrying enough times that we will hit all of the configured DNS servers before failing
    file { '/etc/resolvconf/resolv.conf.d/tail':
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => 'u+rw,go+r',
    }

    file_line { 'resolv.conf dns options':
      path => '/etc/resolvconf/resolv.conf.d/tail',
      line => 'options timeout:1 attempts:4',
    }
  }

  # Keep stuff put in at bootstrap up to date
  file {'/etc/puppet':
    ensure => directory,
    owner  => 'root',
    group  => 'adm',
    mode   => '2775',
  }
  file {'/etc/puppet-bare':
    ensure => directory,
    owner  => 'root',
    group  => 'adm',
    mode   => '2775',
  }
  file {'/etc/puppet-bare/hooks/post-update':
    ensure => file,
    owner  => 'root',
    group  => 'adm',
    mode   => '0775',
    source => 'puppet:///modules/dtg/post-update.hook',
  }
  file {'/etc/puppet/.git/hooks/pre-commit.hook':
    ensure => 'link',
    target => '/etc/puppet/modules/dtg/files/pre-commit.hook',
  }
  file {'/etc/init/failsafe.conf':
    ensure => file,
    owner  => 'root',
    group  => 'adm',
    mode   => '0644',
    source => 'puppet:///modules/dtg/failsafe.conf',
  }

}
