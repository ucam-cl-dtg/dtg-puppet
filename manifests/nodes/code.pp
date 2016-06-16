node 'code.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  class {'apache': }
  class {'dtg::apache::raven': server_description => 'DTG Code Server'}
  class {'dtg::maven':
    sshmirror_keyids => [
    'Daniel Robert Thomas (Computer Lab Key) <drt24@cam.ac.uk>',
    'Oliver Chick <oc243@cam.ac.uk>',
    'Lucian Carata <lc525@cam.ac.uk>',
    'James Snee <jas250@cam.ac.uk>',
    'Andrew Rice <acr31@cam.ac.uk>',
    'Daniel Wagner (ssh) <wagner.daniel.t@gmail.com>',
    'Mattias Linnap <mattias@linnap.com>','Mattias Linnap (llynfi-ssh) <mattias@linnap.com>','Mattias Linnap (macmini-ssh) <mattias@linnap.com>',
    'Thomas Bytheway <thomas.bytheway@cl.cam.ac.uk>',
    'Alastair Beresford (ssh) <arb33@cam.ac.uk>',
    'Ian Davies (ssh) <ipd21@cam.ac.uk>',
    'Ripduman Sohan (Cambridge Key) <ripduman.sohan@cl.cam.ac.uk>',
    'Stephen Cummins (Main key) <sacummins@gmail.com>',
    'Kovacsics Robert (Alias "kr2") <kovirobi@gmail.com>',
    'Tom Lefley <tl364@cam.ac.uk>',
    'Isaac Dunn <ird28@cam.ac.uk>',
    'Alexander Simpson (ssh) <as2388@cam.ac.uk>',
    'Raahil Shah (ssh) <rds46@cam.ac.uk>',
    'Katie Scott (ssh) <kls82@cam.ac.uk>'
    ]
  }
  class {'dtg::firewall::publichttp':}
  class {'dtg::git':}
  class {'dtg::git::mirror::server':}
  Dtg::Git::Mirror::Repo {require => Class['dtg::git::mirror::server'],}
  #List of git repositories to mirror
  # In alphabetical order
  
  #libraries
  dtg::git::mirror::repo{'lib/compilesettingsloader': source => 'git@code.dtg.cl.cam.ac.uk:lib/compilesettingsloader'}
  dtg::git::mirror::repo{'lib/diceware': source => 'git@code.dtg.cl.cam.ac.uk:lib/diceware'}
  dtg::git::mirror::repo{'lib/nigori': source => 'git@code.dtg.cl.cam.ac.uk:lib/nigori'}
  dtg::git::mirror::repo{'lib/openpyxl': source => 'hg::https://bitbucket.org/openpyxl/openpyxl'}
  dtg::git::mirror::repo{'lib/pom': source => 'git@code.dtg.cl.cam.ac.uk:lib/pom'}
  dtg::git::mirror::repo{'lib/regexp': source => 'git@code.dtg.cl.cam.ac.uk:lib/regexp'}
  dtg::git::mirror::repo{'lib/snowdon': source => 'git@code.dtg.cl.cam.ac.uk:lib/snowdon'}

  # android
  dtg::git::mirror::repo{'android/audio/hertz': source => 'git@code.dtg.cl.cam.ac.uk:android/audio/hertz'}
  dtg::git::mirror::repo{'android/audio/spectral': source => 'git@code.dtg.cl.cam.ac.uk:android/audio/spectral'}
  dtg::git::mirror::repo{'android/education/learn': source => 'git@code.dtg.cl.cam.ac.uk:android/education/learn'}
  dtg::git::mirror::repo{'android/nigori/passgori': source => 'git@code.dtg.cl.cam.ac.uk:android/nigori/passgori'}
  dtg::git::mirror::repo{'android/vision/barcodebox': source => 'git@code.dtg.cl.cam.ac.uk:android/vision/barcodebox'}

  # puppet
  dtg::git::mirror::repo{'puppet/dtg-puppet': source => 'git@code.dtg.cl.cam.ac.uk:infrastructure/dtg-puppet'}
  dtg::git::mirror::repo{'puppet/modules/apache': source => 'git://github.com/ucam-cl-dtg/puppet-apache.git'}
  dtg::git::mirror::repo{'puppet/modules/apt': source => 'git://github.com/puppetlabs/puppetlabs-apt.git'}
  dtg::git::mirror::repo{'puppet/modules/common': source => 'git://github.com/puppet-modules/puppet-common.git'}
  dtg::git::mirror::repo{'puppet/modules/concat': source => 'https://github.com/puppetlabs/puppetlabs-concat.git'}
  dtg::git::mirror::repo{'puppet/modules/datacat': source => 'https://github.com/richardc/puppet-datacat.git'}
  dtg::git::mirror::repo{'puppet/modules/dhcp': source => 'https://github.com/puppetlabs/puppetlabs-dhcp.git'}
  dtg::git::mirror::repo{'puppet/modules/distcc': source => 'https://github.com/ucam-cl-dtg/puppet-distcc.git'}
  dtg::git::mirror::repo{'puppet/modules/docker': source => 'https://github.com/garethr/garethr-docker.git'}
  dtg::git::mirror::repo{'puppet/modules/ekeyd': source => 'git://github.com/ucam-cl-dtg/puppet-ekeyd.git'}
  dtg::git::mirror::repo{'puppet/modules/elasticsearch': source => 'https://github.com/elastic/puppet-elasticsearch.git'}
  dtg::git::mirror::repo{'puppet/modules/etckeeper': source => 'git://github.com/thomasvandoren/puppet-etckeeper.git'}
  dtg::git::mirror::repo{'puppet/modules/fileconcat': source => 'https://github.com/electrical/puppet-lib-file_concat.git'}
  dtg::git::mirror::repo{'puppet/modules/firewall': source => 'git://github.com/puppetlabs/puppetlabs-firewall.git'}
  dtg::git::mirror::repo{'puppet/modules/gerrit': source => 'https://github.com/ucam-cl-dtg/puppet-gerrit.git'}
  dtg::git::mirror::repo{'puppet/modules/inifile': source => 'https://github.com/puppetlabs/puppetlabs-inifile.git'}
  dtg::git::mirror::repo{'puppet/modules/java': source => 'https://github.com/puppetlabs/puppetlabs-java.git'}
  dtg::git::mirror::repo{'puppet/modules/kibana': source => 'https://github.com/evenup/evenup-kibana.git'}
  dtg::git::mirror::repo{'puppet/modules/letsencrypt': source => 'https://github.com/danzilio/puppet-letsencrypt.git'}
  dtg::git::mirror::repo{'puppet/modules/logstash': source => 'https://github.com/elastic/puppet-logstash.git'}
  dtg::git::mirror::repo{'puppet/modules/monkeysphere': source => 'https://github.com/ucam-cl-dtg/puppet-monkeysphere'}
  dtg::git::mirror::repo{'puppet/modules/mysql': source => 'git://github.com/puppetlabs/puppetlabs-mysql.git'}
  dtg::git::mirror::repo{'puppet/modules/network': source => 'https://github.com/attachmentgenie/attachmentgenie-network.git'}
  dtg::git::mirror::repo{'puppet/modules/nfs': source => 'https://github.com/stankevich/puppet-nfs.git'}
  dtg::git::mirror::repo{'puppet/modules/ntp': source => 'git://github.com/puppetlabs/puppetlabs-ntp.git'}
  dtg::git::mirror::repo{'puppet/modules/postgresql': source => 'git://github.com/puppetlabs/puppet-postgresql.git'}
  dtg::git::mirror::repo{'puppet/modules/puppetlabs-stdlib': source => 'https://github.com/puppetlabs/puppetlabs-stdlib.git'}
  dtg::git::mirror::repo{'puppet/modules/rabbitmq': source => 'git://github.com/puppetlabs/puppetlabs-rabbitmq.git'}
  dtg::git::mirror::repo{'puppet/modules/rsyslog': source => 'https://github.com/saz/puppet-rsyslog.git'}
  dtg::git::mirror::repo{'puppet/modules/rvm': source => ' https://github.com/lc525/puppet-rvm'}
  dtg::git::mirror::repo{'puppet/modules/shell_config': source => 'git://github.com/puppetlabs-operations/puppet-shell_config.git'}
  dtg::git::mirror::repo{'puppet/modules/smartd': source => 'git://github.com/jhoblitt/puppet-smartd.git'}
  dtg::git::mirror::repo{'puppet/modules/sonarqube': source => 'https://github.com/maestrodev/puppet-sonarqube.git'}
  dtg::git::mirror::repo{'puppet/modules/stdlib': source => 'git://github.com/puppetlabs/puppetlabs-stdlib.git'}
  dtg::git::mirror::repo{'puppet/modules/stunnel': source => 'git://github.com/ucam-cl-dtg/blendedbyus-stunnel.git'}
  dtg::git::mirror::repo{'puppet/modules/sudoers': source => 'git://github.com/phinze/puppet-sudoers.git'}
  dtg::git::mirror::repo{'puppet/modules/sysctl': source => 'git://github.com/duritong/puppet-sysctl.git'}
  dtg::git::mirror::repo{'puppet/modules/unbound': source => 'https://github.com/xaque208/puppet-unbound.git'}
  dtg::git::mirror::repo{'puppet/modules/vcsrepo': source => 'https://github.com/puppetlabs/puppetlabs-vcsrepo'}
  dtg::git::mirror::repo{'puppet/modules/virt': source => 'https://github.com/carlasouza/puppet-virt.git'}
  dtg::git::mirror::repo{'puppet/modules/vmutil': source => 'https://github.com/ucam-cl-dtg/puppet-vmutil.git'}
  dtg::git::mirror::repo{'puppet/modules/wget': source => 'git://github.com/maestrodev/puppet-wget.git'}
  dtg::git::mirror::repo{'puppet/modules/zfs-auto-snapshot': source => 'https://github.com/ucam-cl-dtg/puppet-zfs-auto-snapshot.git'}


  # cdn
  dtg::git::mirror::repo{'isaac/cdn': source => 'git@code.dtg.cl.cam.ac.uk:isaac/cdn'}


  #time project - transport
  dtg::git::mirror::repo{'time/batchupdaters': source => 'git@code.dtg.cl.cam.ac.uk:time/batchupdaters'}
  dtg::git::mirror::repo{'time/minibus': source => 'git@code.dtg.cl.cam.ac.uk:time/minibus'}
  dtg::git::mirror::repo{'time/timebase': source => 'git@code.dtg.cl.cam.ac.uk:time/timebase'}
  dtg::git::mirror::repo{'time/transport-server': source => 'git@code.dtg.cl.cam.ac.uk:time/transport-server'}

  #web
  dtg::git::mirror::repo{'web/dtg-www': source => 'git@code.dtg.cl.cam.ac.uk:web/dtg-www'}
  dtg::git::mirror::repo{'web/noop-filter': source => 'git@code.dtg.cl.cam.ac.uk:web/noop-filter'}
  #web/raven
  dtg::git::mirror::repo{'web/raven/mod_ucam_webauth': source => 'git@code.dtg.cl.cam.ac.uk:web/raven/mod_ucam_webauth'}
  dtg::git::mirror::repo{'web/raven/webauth': source => 'git@code.dtg.cl.cam.ac.uk:web/raven/webauth'}
  dtg::git::mirror::repo{'web/raven/webauth-tomcat': source => 'git@code.dtg.cl.cam.ac.uk:web/raven/webauth-tomcat'}

  dtg::git::mirror::repo{'web/readyourmeter': source => 'git@code.dtg.cl.cam.ac.uk:web/readyourmeter'}

  #husky/scripts
  dtg::git::mirror::repo{'husky/preseed': source => 'git@code.dtg.cl.cam.ac.uk:husky/preseed'}
  dtg::git::mirror::repo{'husky/scripts': source => 'git@code.dtg.cl.cam.ac.uk:husky/scripts'}

  #dtg::git::mirror::repo{'': source => 'git@code.dtg.cl.cam.ac.uk:'}
  #dtg::git::mirror::repo{'': source => ''}

}
if ( $::is_backup_server ) {
  dtg::backup::hostsetup{'git_repositories':
    user    => 'git',
    host    => 'code.dtg.cl.cam.ac.uk',
    require => Class['dtg::backup::host'],
    weekday => 'Saturday',
  }
  dtg::backup::hostsetup{'nexus_repositories':
    user    => 'nexus',
    host    => 'code.dtg.cl.cam.ac.uk',
    weekday => 'Saturday',
    require => Class['dtg::backup::host'],
  }
}

if ( $::monitor ) {
  nagios::monitor { 'code':
    parents    => 'nas04',
    address    => 'code.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
  nagios::monitor { 'maven':
    parents                     => 'code',
    address                     => 'maven.dtg.cl.cam.ac.uk',
    hostgroups                  => [ 'http-servers' ],
    include_standard_hostgroups => false,
  }
  nagios::monitor { 'git':
    parents                     => 'code',
    address                     => 'git.dtg.cl.cam.ac.uk',
    hostgroups                  => [ 'http-servers' ],
    include_standard_hostgroups => false,
  }
  munin::gatherer::configure_node { 'code': }
}
