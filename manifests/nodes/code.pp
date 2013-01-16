node 'code.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  class {'apache': }
  class {'dtg::apache::raven': server_description => 'DTG Code Server'}
  class {'dtg::maven': }
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
  dtg::git::mirror::repo{'puppet/modules/ekeyd': source => 'git://github.com/ucam-cl-dtg/puppet-ekeyd.git'}
  dtg::git::mirror::repo{'puppet/modules/etckeeper': source => 'git://github.com/thomasvandoren/puppet-etckeeper.git'}
  dtg::git::mirror::repo{'puppet/modules/firewall': source => 'git://github.com/puppetlabs/puppetlabs-firewall.git'}
  dtg::git::mirror::repo{'puppet/modules/mysql': source => 'git://github.com/puppetlabs/puppetlabs-mysql.git'}
  dtg::git::mirror::repo{'puppet/modules/ntp': source => 'git://github.com/puppetlabs/puppetlabs-ntp.git'}
  dtg::git::mirror::repo{'puppet/modules/sonar': source => 'git://github.com/ucam-cl-dtg/puppet-sonar.git'}
  dtg::git::mirror::repo{'puppet/modules/stdlib': source => 'git://github.com/puppetlabs/puppetlabs-stdlib.git'}
  dtg::git::mirror::repo{'puppet/modules/stunnel': source => 'git://github.com/ucam-cl-dtg/blendedbyus-stunnel.git'}
  dtg::git::mirror::repo{'puppet/modules/sudoers': source => 'git://github.com/phinze/puppet-sudoers.git'}
  dtg::git::mirror::repo{'puppet/modules/sysctl': source => 'git://git.puppet.immerda.ch/module-sysctl.git'}
  dtg::git::mirror::repo{'puppet/modules/vcsrepo': source => 'git://github.com/openstack-ci/puppet-vcsrepo.git'}
  dtg::git::mirror::repo{'puppet/modules/wget': source => 'git://github.com/maestrodev/puppet-wget.git'}
  dtg::git::mirror::repo{'puppet/modules/postgresql': source => 'git://github.com/puppetlabs/puppet-postgresql.git'}

  #time project - transport
  dtg::git::mirror::repo{'time/batchupdaters': source => 'git@code.dtg.cl.cam.ac.uk:time/batchupdaters'}
  dtg::git::mirror::repo{'time/minibus': source => 'git@code.dtg.cl.cam.ac.uk:time/minibus'}
  dtg::git::mirror::repo{'time/timebase': source => 'git@code.dtg.cl.cam.ac.uk:time/timebase'}
  dtg::git::mirror::repo{'time/transport-server': source => 'git@code.dtg.cl.cam.ac.uk:time/transport-server'}

  #web
  dtg::git::mirror::repo{'web/noop-filter': source => 'git@code.dtg.cl.cam.ac.uk:web/noop-filter'}
  #web/raven
  dtg::git::mirror::repo{'web/raven/mod_ucam_webauth': source => 'git@code.dtg.cl.cam.ac.uk:web/raven/mod_ucam_webauth'}
  dtg::git::mirror::repo{'web/raven/webauth': source => 'git@code.dtg.cl.cam.ac.uk:web/raven/webauth'}
  dtg::git::mirror::repo{'web/raven/webauth-tomcat': source => 'git@code.dtg.cl.cam.ac.uk:web/raven/webauth-tomcat'}

  dtg::git::mirror::repo{'web/readyourmeter': source => 'git@code.dtg.cl.cam.ac.uk:web/readyourmeter'}

  #husky/scripts
  dtg::git::mirror::repo{'husky/scripts': source => 'git@code.dtg.cl.cam.ac.uk:husky/scripts'}

  #dtg::git::mirror::repo{'': source => 'git@code.dtg.cl.cam.ac.uk:'}
  #dtg::git::mirror::repo{'': source => ''}

}
if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios::monitor { 'code':
    parents    => '',
    address    => 'code.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
  nagios::monitor { 'maven':
    parents    => 'code',
    address    => 'dtg-maven.cl.cam.ac.uk',
    hostgroups => [ 'http-servers' ],
    include_standard_hostgroups => false,
  }
  nagios::monitor { 'git':
    parents    => 'code',
    address    => 'git.dtg.cl.cam.ac.uk',
    hostgroups => [ 'http-servers' ],
    include_standard_hostgroups => false,
  }
}
if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'code': }
}
