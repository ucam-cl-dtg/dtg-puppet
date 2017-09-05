# Global configuration settings

Exec {
  path      => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin',
  logoutput => 'on_failure',
}

Cron {
  environment => 'MAILTO=dtg-infra@cl.cam.ac.uk',
}

$org_domain = 'dtg.cl.cam.ac.uk'

$from_address = 'dtg-infra@cl.cam.ac.uk'

$ntp_servers = [
  'ntp2.csx.cam.ac.uk',
  'ntp1.csx.cam.ac.uk',
  'ntp1a.cl.cam.ac.uk',
  'ntp1b.cl.cam.ac.uk',
  'ntp1c.cl.cam.ac.uk',
]

$name_servers = [ # '128.232.21.15', Removed DTG DNS. Some software (NFS)
                  # doesn't failover nicely. This means that when dns.dtg goes
                  # down, all of the DTG services stop working as nas04 dies.
                  '131.111.8.42',
                  '131.111.12.20',
                  '128.232.1.1',
                  '128.232.1.2',
                  '128.232.1.3' ]

$dns_name_servers = join($::name_servers, ' ')

# Id certifiers people who can sign other users keys to certify them
class ms_id_certifiers { # lint:ignore:autoloader_layout config-class
  monkeysphere::add_id_certifier {
    'drt24': keyid => '5017A1EC0B2908E3CF647CCD551435D5D74933D9'
  }
  monkeysphere::add_id_certifier {
    'drt24-laptop': keyid => 'EA14782BFF32D5B8464B92D7B2FB14CF18EB83B1'
  }
  monkeysphere::add_id_certifier {
    'acr31': keyid => '43BF45D11B36F45C3F07DA49BDB889325CACF039'
  }
}
# Admin users to be given an account on all machines
group { 'dtg-adm':
  ensure => present,
}
# Delegated administration of central services
group { 'scm-adm':
  ensure => present,
}
group { 'weather-adm':
  ensure => present,
}
group { 'wiki-adm':
  ensure => present,
}

# Research projects
group { 'africa':
  ensure => present,
}
group { 'deviceanalyzer':
  ensure => present,
}
group { 'isaac':
  ensure => present,
}
group { 'rscfl':
  ensure => present,
}
group { 'neat':
  ensure => present,
}

class admin_users ($user_whitelist = undef) { #lint:ignore:autoloader_layout
  dtg::add_user { 'drt24':
    real_name      => 'Daniel Thomas',
    groups         => [ 'adm', 'deviceanalyzer', 'dtg-adm', 'cccc-data' ],
    keys           => [
      'Daniel Robert Thomas (Computer Lab Key) <drt24@cam.ac.uk>'],
    uid            => 2607,
    user_whitelist => $user_whitelist,
  }
  dtg::add_user { 'oc243':
    real_name      => 'Oliver Chick',
    groups         => [ 'adm', 'dtg-adm', 'rscfl'],
    keys           => 'Oliver Chick <oc243@cam.ac.uk>',
    uid            => 2834,
    user_whitelist => $user_whitelist,
  }
  dtg::add_user { 'lc525':
    real_name      => 'Lucian Carata',
    groups         => ['weather-adm', 'wiki-adm', 'rscfl'],
    keys           => 'Lucian Carata <lc525@cam.ac.uk>',
    uid            => 2925,
    user_whitelist => $user_whitelist,
  }
#  dtg::add_user { 'jas250':
#    real_name      => 'James Snee',
#    groups         => ['rscfl'],
#    keys           => 'James Snee <jas250@cam.ac.uk>',
#    uid            => 2814,
#    user_whitelist => $user_whitelist,
#  }
  dtg::add_user { 'acr31':
    real_name      => 'Andrew Rice',
    groups         => ['adm', 'dtg-adm','weather-adm', 'wiki-adm'],
    keys           => 'Andrew Rice <acr31@cam.ac.uk>',
    uid            => 2132,
    user_whitelist => $user_whitelist,
  }
# dtg::add_user { 'dtw30':
#   real_name      => 'Daniel Wagner',
#   groups         => [],
#   keys           => 'Daniel Wagner (ssh) <wagner.daniel.t@gmail.com>',
#   uid            => 2712,
#   user_whitelist => $user_whitelist,
# }
# dtg::add_user { 'ml421':
#   real_name      => 'Mattias Linnap',
#   groups         => [],
#   keys           => ['Mattias Linnap <mattias@linnap.com>',
#                      'Mattias Linnap (llynfi-ssh) <mattias@linnap.com>',
#                      'Mattias Linnap (macmini-ssh) <mattias@linnap.com>'],
#   uid            => 2610,
#   user_whitelist => $user_whitelist,
# }
  dtg::add_user { 'tb403':
    real_name      => 'Thomas Bytheway',
    groups         => [ 'scm-adm' ],
    keys           => ['Thomas Bytheway <thomas.bytheway@cl.cam.ac.uk>'],
    uid            => 3105,
    user_whitelist => $user_whitelist,
  }
  dtg::add_user { 'arb33':
    real_name      => 'Alastair Beresford',
    groups         => [ 'isaac','adm','dtg-adm', 'cccc-data' ],
    keys           => ['Alastair Beresford (ssh) <arb33@cam.ac.uk>'],
    uid            => 2125,
    user_whitelist => $user_whitelist,
  }
  dtg::add_user { 'ipd21':
    real_name      => 'Ian Davies',
    groups         => [ 'isaac' ],
    keys           => ['Ian Davies (ssh) <ipd21@cam.ac.uk>'],
    uid            => 2361,
    user_whitelist => $user_whitelist,
  }
  dtg::add_user { 'rss39':
    real_name      => 'Ripduman Sohan',
    groups         => [ 'africa', 'rscfl' ],
    keys           => [
      'Ripduman Sohan (Cambridge Key) <ripduman.sohan@cl.cam.ac.uk>'],
    uid            => 2134,
    user_whitelist => $user_whitelist,
  }
#  dtg::add_user { 'sa497':
#    real_name      => 'Sherif Akoush',
#    groups         => [ 'africa' ],
#    keys           => ['sa497 <sa497@cam.ac.uk>'],
#    uid            => 2412,
#    user_whitelist => $user_whitelist,
#  }
  dtg::add_user { 'sac92':
    real_name      => 'Stephen Cummins',
    groups         => [ 'isaac' ],
    keys           => ['Stephen Cummins (Main key) <sacummins@gmail.com>'],
    uid            => 3286,
    user_whitelist => $user_whitelist,
  }
# dtg::add_user { 'ags46':
#   real_name      => 'Alistair Stead',
#   groups         => [ 'isaac' ],
#   keys           => ['Alistair Stead <ags46@cam.ac.uk>'],
#   uid            => 2815,
#   user_whitelist => $user_whitelist,
# }

  dtg::add_user { 'sak70':
    real_name      => 'Stephan Kollmann',
    groups         => [],
    keys           => [
      'Stephan Kollmann (Computer Laboratory) <sak70@cam.ac.uk>'],
    uid            => 3361,
    user_whitelist => $user_whitelist,
  }
  dtg::add_user { 'dwt27':
    real_name      => 'David Turner',
    groups         => [ 'weather-adm' ],
    keys           => ['David W. Turner <david.w.turner@cl.cam.ac.uk>'],
    uid            => 3195,
    user_whitelist => $user_whitelist,
  }
#  dtg::add_user { 'dh526':
#    real_name      => 'Daniel Hintze',
#    groups         => [],
#    keys           => ['Daniel Hintze <daniel@hintze-it.de>'],
#    uid            => 3451,
#    user_whitelist => $user_whitelist,
#  }
  dtg::add_user { 'dac53':
    real_name      => 'Diana Vasile',
    groups         => ['adm', 'deviceanalyzer', 'dtg-adm'],
    keys           => ['Diana Vasile <dac53@cam.ac.uk>'],
    uid            => 3252,
    user_whitelist => $user_whitelist,
  }
  dtg::add_user { 'mojpc2':
    real_name      => 'Mistral Contrastin',
    groups         => [],
    keys           => ['Mistral CONTRASTIN <mojpc2@cam.ac.uk>'],
    uid            => 3476,
    user_whitelist => $user_whitelist,
  }
#  dtg::add_user { 'amiae2':
#    real_name      => 'Ahmed Elmezeini',
#    groups         => [],
#    keys           => ['Ahmed Elmezeini <amiae2@cam.ac.uk>'],
#    uid            => 3581,
#    user_whitelist => $user_whitelist,
#  }
  dtg::add_user { 'af599':
    real_name      => 'Andrea Franceschini',
    groups         => [ 'isaac' ],
    keys           => ['Andrea Franceschini (porto) <af599@cam.ac.uk>',
                      'Andrea Franceschini (omoikane) <af599@cam.ac.uk>'],
    uid            => 3619,
    user_whitelist => $user_whitelist,
  }
  # dtg::add_user { 'jk672':
  #   real_name      => 'Nicolas Karsten',
  #   groups         =>  [],
  #   keys           => ['Nicolas Karsten <karsten@dice.hhu.de>'],
  #   uid            => 3633,
  #   user_whitelist => $user_whitelist,
  # }
  dtg::add_user { 'jps79':
    real_name      => 'James Sharkey',
    groups         =>  ['isaac'],
    keys           => ['James Sharkey (CL) <jps79@cam.ac.uk>'],
    uid            => 3622,
    user_whitelist => $user_whitelist,
  }
  dtg::add_user { 'mlt47':
    real_name      => 'Meurig Thomas',
    groups         =>  ['isaac'],
    keys           => ['Meurig Thomas (ssh) <mlt47@cam.ac.uk>'],
    uid            => 3840,
    user_whitelist => $user_whitelist,
  }
  dtg::add_user { 'du220':
    real_name      => 'Daniel Underwood',
    groups         =>  ['isaac'],
    keys           => ['Daniel Underwood (ssh) <du220@cam.ac.uk>'],
    uid            => 3845,
    user_whitelist => $user_whitelist,
  }

  dtg::add_user { 'rjm49':
    real_name      => 'Russell Moore',
    groups         =>  [],
    keys           => ['Russell Moore <rjm49@cam.ac.uk>'],
    uid            => 3651,
    user_whitelist => $user_whitelist,
  }
  dtg::add_user { 'mrd45':
    real_name      => 'Matthew Danish',
    groups         => [],
    keys           => ['Matthew Danish <mrd45@cam.ac.uk>'],
    uid            => 3541,
    user_whitelist => $user_whitelist,
  }

  dtg::add_user { 'mk428':
    real_name      => 'Martin Kleppmann',
    groups         => [],
    keys           => ['Martin Kleppmann <mk428@cam.ac.uk>'],
    uid            => 2628,
    user_whitelist => $user_whitelist,
  }

  dtg::add_user { 'akmf3':
    real_name      => 'Ayat Fekry',
    groups         => ['neat'],
    keys           => ['akmf3 <akmf3@cl.cam.ac.uk>'],
    uid            => 3701,
    user_whitelist => $user_whitelist,
  }

  # System users which need to be present on all machines
  # This applies for example if the user needs to write data which
  # is nfs mounted
  group { 'www-deviceanalyzer' :
    gid => 40000,
  }
  ->
  user { 'www-deviceanalyzer' :
    ensure   => present,
    comment  => 'DeviceAnalyzer WWW user',
    shell    => '/usr/sbin/nologin',
    groups   => 'www-deviceanalyzer',
    uid      => 40000,
    gid      => 40000,
    password => '*',
  }
  # On africa01 hadoop is 40001
  group { 'cccc-data' :
    gid => 40002,
  }
  ->
  user { 'cccc-data' :
    ensure   => present,
    comment  => 'CCCC data user',
    shell    => '/usr/sbin/nologin',
    groups   => 'cccc-data',
    uid      => 40002,
    gid      => 40002,
    password => '*',
  }
  # user for backups
  group { 'cccc-backup':
    ensure => present,
    gid    => 40003,
  }
  user { 'cccc-backup':
    ensure   => present,
    comment  => 'CCCC backup user',
    password => '*',
    gid      => 40003,
    uid      => 40003,
    home     => '/home/cccc-backup/',
  }

    
}
# Admin user ids to be given root on the nodes via monkeysphere
$ms_admin_user_ids = [
  'Daniel Robert Thomas (Computer Lab Key) <drt24@cam.ac.uk>',
  'Andrew Rice <acr31@cam.ac.uk>'
]
# Keyserver with the public keys to use for monkeysphere
$ms_keyserver = 'keyserver.ubuntu.com'
$ms_gpg_passphrase = 'not a secret passphrase - we rely on unix user protection'

# Email config
$smtp_server = 'mail-serv.cl.cam.ac.uk'

# Nagios config
$nagios_machine_fqdn = "monitor.${org_domain}"
$nagios_server = "nagios.${org_domain}"
$nagios_ssl = false
$nagios_from_emailaddress = $from_address
$nagios_alert_emailaddress = $nagios_from_emailaddress
$nagios_org_name = 'Digital Technology Group'
$nagios_org_url = 'https://www.cl.cam.ac.uk/research/dtg/'

#Munin config
$munin_ssl = true
$munin_machine_fqdn = $nagios_machine_fqdn
$munin_server = "munin.${org_domain}"
$munin_server_ip_array = dnsLookup($munin_server)
$munin_server_ip = $munin_server_ip_array[0]

if ( $::fqdn =~ /(monitor|prism).dtg.cl.cam.ac.uk/ ) {
  $monitor = true
} else {
  $monitor = false
}

# Unattended upgrade config
$unattended_upgrade_notify_emailaddress = $from_address

#Firewall config
$local_subnet = '128.232.0.0/17'
$dtg_subnet = '128.232.20.0/22'

# Backup config
$backup_hosts = ['africa01.dtg.cl.cam.ac.uk']

if ( $::fqdn in $backup_hosts ) {
  $is_backup_server= true
} else {
  $is_backup_server = false
}

$nfs_client_port = 1025


# Configure git push to deploy
exec { 'git-push-to-deploy':
  command => 'git config receive.denyCurrentBranch updateInstead',
  unless  => 'git config --get receive.denyCurrentBranch | grep updateInstead',
  cwd     => '/etc/puppet',
}
