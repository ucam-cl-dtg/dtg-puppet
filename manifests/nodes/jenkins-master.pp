node 'jenkins-master.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  class { 'dtg::jenkins': }
  class { 'sonar': version => '3.2'}
}

package { "gradle": ensure => "installed" }

wget::fetch { "download-gradle-plugin":
  source => "\"https://updates.jenkins-ci.org/download/plugins/gradle/1.21/gradle.hpi\"",
  destination => "/var/lib/jenkins/plugins/gradle.hpi"
}

wget::fetch { "gradlew setup":
  source => "\"http://services.gradle.org/distributions/gradle-1.4-all.zip\"",
  destination => "/var/lib/jenkins/workspace/external/gradle/gradle-1.4-all.zip"
}

if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios::monitor { 'jenkins-master':
    parents    => '',
    address    => 'jenkins-master.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers' ],
  }
}
if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'jenkins-master': }
}
